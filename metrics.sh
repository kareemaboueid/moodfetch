#!/usr/bin/env bash
# Collects system metrics in a best-effort, portable manner.
# Exports variables that the mood engine and templates rely on.

# Defaults so renderers never crash even if a probe fails
battery_pct=""
cpu_temp=""
cpu_util_pct=""
load_per_core=""
ram_pct=""
swap_pct=""
disk_pct=""
iowait_pct=""
uptime_h=""
iface=""
wifi_signal=""
top_proc=""
distro=""
kernel=""
hostname=""
profile=""
volume_pct=""
gpu_model=""

# ----- OS / identity -----
probe_os_identity() {
  hostname="$(hostname 2>/dev/null || echo "localhost")"
  kernel="$(uname -r 2>/dev/null || echo "unknown-kernel")"
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    distro="${PRETTY_NAME:-$NAME $VERSION}"
  else
    distro="$(uname -s 2>/dev/null || echo "unknown-OS")"
  fi
}

# ----- Battery -----
probe_battery() {
  # Most laptops expose BAT0, sometimes BAT1
  local bat
  for bat in /sys/class/power_supply/BAT{0,1}; do
    if [ -d "$bat" ]; then
      if [ -r "${bat}/capacity" ]; then
        battery_pct="$(cat "${bat}/capacity" 2>/dev/null | tr -dc '0-9')"
      fi
      # No need to export charging state for templates, engine reads raw files if needed
      break
    fi
  done
}

# ----- CPU load & util -----
probe_cpu() {
  # 1-min load normalized by cores
  local la1 cores
  la1="$(awk '{print $1}' /proc/loadavg 2>/dev/null)"
  cores="$(nproc 2>/dev/null || echo 1)"
  if [ -n "${la1}" ] && [ -n "${cores}" ]; then
    load_per_core="$(awk -v l="${la1}" -v c="${cores}" 'BEGIN{printf("%.2f",l/c)}')"
  fi

  # Quick utilization sample based on /proc/stat delta (lightweight)
  # NOTE: reduced sleep to 0.02s for faster response (instead of 0.10s).
  local a b idle_a idle_b total_a total_b totald idled
  a="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  # fast-exit if no data
  [ -z "$a" ] && return
  sleep 0.02
  b="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$b" ] && return

  # shellcheck disable=SC2206
  a=($a)
  # shellcheck disable=SC2206
  b=($b)
  idle_a=$((a[4]+a[5])); idle_b=$((b[4]+b[5]))
  total_a=0; for i in "${a[@]:1}"; do total_a=$((total_a+i)); done
  total_b=0; for i in "${b[@]:1}"; do total_b=$((total_b+i)); done
  totald=$((total_b-total_a))
  idled=$((idle_b-idle_a))
  if [ "${totald}" -gt 0 ]; then
    cpu_util_pct="$(awk -v t="${totald}" -v i="${idled}" 'BEGIN{printf("%.0f",(1 - i/t)*100)}')"
  fi
}

# ----- CPU temperature (best-effort) -----
probe_cpu_temp() {
  local tf
  tf="$(find /sys/class/thermal -type f -name temp 2>/dev/null | head -n1)"
  if [ -n "${tf}" ]; then
    local raw
    raw="$(cat "${tf}" 2>/dev/null)"
    if [ -n "${raw}" ]; then
      cpu_temp="$((raw/1000))"
    fi
  fi
}

# ----- Memory -----
probe_memory() {
  local mem_total mem_avail swap_total swap_free
  mem_total="$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)"
  mem_avail="$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null)"
  if [ -n "${mem_total}" ] && [ -n "${mem_avail}" ] && [ "${mem_total}" -gt 0 ]; then
    ram_pct="$(awk -v t="${mem_total}" -v a="${mem_avail}" 'BEGIN{printf("%.0f",(1-(a/t))*100)}')"
  fi
  swap_total="$(awk '/SwapTotal/ {print $2}' /proc/meminfo 2>/dev/null)"
  swap_free="$(awk '/SwapFree/ {print $2}' /proc/meminfo 2>/dev/null)"
  if [ -n "${swap_total}" ] && [ "${swap_total}" -gt 0 ] && [ -n "${swap_free}" ]; then
    swap_pct="$(awk -v t="${swap_total}" -v f="${swap_free}" 'BEGIN{printf("%.0f",((t-f)/t)*100)}')"
  fi
}

# ----- Disk -----
probe_disk() {
  # Root filesystem usage percentage as integer
  disk_pct="$(df -P / 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5); print $5}')"
}

# ----- I/O wait (approx) -----
probe_iowait() {
  # Use /proc/stat deltas similar to CPU util
  # NOTE: reduced sleep to 0.02s for faster response (instead of 0.10s).
  local a b total_a total_b idle_a idle_b iow_a iow_b totald iowd
  a="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$a" ] && return
  sleep 0.02
  b="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$b" ] && return

  # shellcheck disable=SC2206
  a=($a); b=($b)
  iow_a="${a[5]}"; iow_b="${b[5]}"
  total_a=0; for i in "${a[@]:1}"; do total_a=$((total_a+i)); done
  total_b=0; for i in "${b[@]:1}"; do total_b=$((total_b+i)); done
  totald=$((total_b-total_a))
  iowd=$((iow_b-iow_a))
  if [ "${totald}" -gt 0 ]; then
    iowait_pct="$(awk -v t="${totald}" -v w="${iowd}" 'BEGIN{printf("%.0f",(w/t)*100)}')"
  fi
}

# ----- Uptime -----
probe_uptime() {
  uptime_h="$(awk '{printf("%.0f",$1/3600)}' /proc/uptime 2>/dev/null)"
}

# ----- Network connectivity + iface type + wifi signal (best-effort) -----
probe_network() {
  # online/offline test
  if has_cmd ping && ping -q -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
    :
  else
    :
  fi
  # get active interface guess (very rough without NetworkManager)
  iface="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"
  if [ -z "${iface}" ]; then
    iface="$(ip -o link 2>/dev/null | awk -F': ' '{print $2}' | head -n1)"
  fi
  # Wi-Fi signal via nmcli if available
  if has_cmd nmcli; then
    wifi_signal="$(nmcli -t -f ACTIVE,SIGNAL dev wifi | awk -F: '$1=="yes"{print $2; exit}')"
  fi

  # Graceful fallback: if no wifi_signal and iface not Wi-Fi, clear it to avoid false positives
  if [ -z "${wifi_signal}" ]; then
    if ! printf '%s' "${iface}" | grep -qiE 'wl|wifi|wlan'; then
      wifi_signal=""
    fi
  fi
}

# ----- Top process name (rough) -----
probe_top_process() {
  if has_cmd ps; then
    top_proc="$(ps -eo comm,%cpu,%mem --sort=-%cpu,-%mem 2>/dev/null | awk 'NR==2{print $1}')"
  fi
}

# ----- Audio volume (pactl/amixer) -----
probe_audio() {
  if has_cmd pactl; then
    volume_pct="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%' | head -n1)"
  elif has_cmd amixer; then
    volume_pct="$(amixer get Master 2>/dev/null | grep -o '[0-9]\+%' | head -n1 | tr -d '%')"
  fi
}

# ----- Power profile (optional) -----
probe_power_profile() {
  if has_cmd powerprofilesctl; then
    profile="$(powerprofilesctl get 2>/dev/null)"
  else
    profile="balanced"
  fi
}

# ----- GPU model (very rough, multiple fallbacks) -----
probe_gpu() {
  # First try lspci (classic fallback)
  if has_cmd lspci; then
    gpu_model="$(lspci 2>/dev/null | awk -F': ' '/ VGA | 3D /{print $3; exit}')"
  elif has_cmd glxinfo; then
    # glxinfo can sometimes show the renderer string
    gpu_model="$(glxinfo 2>/dev/null | awk -F': ' '/renderer string/{print $2; exit}')"
  elif has_cmd nvidia-smi; then
    # nvidia-smi -L prints GPU model if NVIDIA card present
    gpu_model="$(nvidia-smi -L 2>/dev/null | head -n1 | cut -d':' -f2- | xargs)"
  else
    gpu_model=""
  fi
}

# Public: gather everything in one go
collect_all_metrics() {
  probe_os_identity
  probe_battery
  probe_cpu
  probe_cpu_temp
  probe_memory
  probe_disk
  probe_iowait
  probe_uptime
  probe_network
  probe_top_process
  probe_audio
  probe_power_profile
  probe_gpu

  # Normalize a few to integers if needed
  cpu_util_pct="$(to_int_pct "${cpu_util_pct}")"
  ram_pct="$(to_int_pct "${ram_pct}")"
  swap_pct="$(to_int_pct "${swap_pct}")"
  disk_pct="$(to_int_pct "${disk_pct}")"
  iowait_pct="$(to_int_pct "${iowait_pct}")"
  uptime_h="$(to_int_pct "${uptime_h}")"
  wifi_signal="$(to_int_pct "${wifi_signal}")"
  volume_pct="$(to_int_pct "${volume_pct}")"
}
