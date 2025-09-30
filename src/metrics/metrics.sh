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

# Bandwidth metrics
net_rx_bps=""       # Network receive bandwidth in bytes/sec
net_tx_bps=""       # Network transmit bandwidth in bytes/sec
process_count=""    # Total running processes
disk_read_bps=""    # Disk read bandwidth in bytes/sec
disk_write_bps=""   # Disk write bandwidth in bytes/sec

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
      break
    fi
  done
}

# ----- CPU load & util -----
probe_cpu() {
  local la1 cores
  la1="$(awk '{print $1}' /proc/loadavg 2>/dev/null)"
  cores="$(nproc 2>/dev/null || echo 1)"
  if [ -n "${la1}" ] && [ -n "${cores}" ]; then
    load_per_core="$(awk -v l="${la1}" -v c="${cores}" 'BEGIN{printf("%.2f",l/c)}')"
  fi

  local a b idle_a idle_b total_a total_b totald idled
  a="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$a" ] && return
  sleep 0.02
  b="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$b" ] && return

  a=($a); b=($b)
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
  disk_pct="$(df -P / 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5); print $5}')"
}

# ----- I/O wait -----
probe_iowait() {
  local a b total_a total_b idle_a idle_b iow_a iow_b totald iowd
  a="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$a" ] && return
  sleep 0.02
  b="$(grep '^cpu ' /proc/stat 2>/dev/null)"
  [ -z "$b" ] && return

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

# ----- Network -----
probe_network() {
  iface="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"
  if [ -z "${iface}" ]; then
    iface="$(ip -o link 2>/dev/null | awk -F': ' '{print $2}' | head -n1)"
  fi
  if has_cmd nmcli && printf '%s' "${iface}" | grep -qiE 'wl|wifi|wlan'; then
    wifi_signal="$(nmcli -t -f ACTIVE,SIGNAL dev wifi | awk -F: '$1=="yes"{print $2; exit}')"
  else
    wifi_signal=""
  fi
}

# ----- Top process -----
probe_top_process() {
  if has_cmd ps; then
    top_proc="$(ps -eo comm,%cpu,%mem --sort=-%cpu,-%mem 2>/dev/null | awk 'NR==2{print $1}')"
  fi
}

# ----- Audio -----
probe_audio() {
  if has_cmd pactl; then
    volume_pct="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%' | head -n1)"
  elif has_cmd amixer; then
    volume_pct="$(amixer get Master 2>/dev/null | grep -o '[0-9]\+%' | head -n1 | tr -d '%')"
  fi
}

# ----- Power profile -----
probe_power_profile() {
  if has_cmd powerprofilesctl; then
    profile="$(powerprofilesctl get 2>/dev/null)"
  else
    profile="balanced"
  fi
}

# ----- Process count -----
probe_process_count() {
  process_count="$(ps -e 2>/dev/null | wc -l)" || true
}

# ----- Network bandwidth -----
probe_network_bandwidth() {
  local dev rx_bytes tx_bytes
  # Try to use the first active interface
  dev="$(ip -br link show up 2>/dev/null | grep -v 'lo' | head -n1 | cut -d' ' -f1)" || return
  if [ -z "$dev" ]; then
    return
  fi

  # Read initial values
  rx_bytes="$(cat "/sys/class/net/$dev/statistics/rx_bytes" 2>/dev/null)" || return
  tx_bytes="$(cat "/sys/class/net/$dev/statistics/tx_bytes" 2>/dev/null)" || return
  
  # Wait a short interval
  sleep 0.1
  
  # Read final values
  local rx_bytes2 tx_bytes2
  rx_bytes2="$(cat "/sys/class/net/$dev/statistics/rx_bytes" 2>/dev/null)" || return
  tx_bytes2="$(cat "/sys/class/net/$dev/statistics/tx_bytes" 2>/dev/null)" || return
  
  # Calculate rates (bytes per second)
  net_rx_bps="$(( (rx_bytes2 - rx_bytes) * 10 ))"
  net_tx_bps="$(( (tx_bytes2 - tx_bytes) * 10 ))"
}

# ----- Disk I/O rates -----
probe_disk_io() {
  local dev sectors_read sectors_read2 sectors_write sectors_write2
  
  # Try to use the first block device (usually sda or nvme0n1)
  dev="$(lsblk -d -n -o NAME 2>/dev/null | head -n1)" || return
  if [ -z "$dev" ]; then
    return
  fi

  # Read initial values
  sectors_read="$(cat "/sys/block/$dev/stat" 2>/dev/null | awk '{print $3}')" || return
  sectors_write="$(cat "/sys/block/$dev/stat" 2>/dev/null | awk '{print $7}')" || return
  
  # Wait a short interval
  sleep 0.1
  
  # Read final values
  sectors_read2="$(cat "/sys/block/$dev/stat" 2>/dev/null | awk '{print $3}')" || return
  sectors_write2="$(cat "/sys/block/$dev/stat" 2>/dev/null | awk '{print $7}')" || return
  
  # Calculate rates (bytes per second), assuming 512-byte sectors
  disk_read_bps="$(( (sectors_read2 - sectors_read) * 5120 ))"  # *512/0.1
  disk_write_bps="$(( (sectors_write2 - sectors_write) * 5120 ))"
}

# Public: gather everything in one go
collect_all_metrics() {
  log_debug "Starting metrics collection on $CURRENT_OS"
  
  # Only support Linux - warn and continue with basic probes for other OS
  if [ "$CURRENT_OS" != "$OS_LINUX" ]; then
    log_warn "Unsupported OS: $CURRENT_OS - limited functionality"
    probe_os_identity
    return
  fi
  
  # Linux-specific metrics collection
  log_debug "Collecting Linux system metrics"
  
  # Start background probes first
  probe_os_identity &
  probe_process_count &
  probe_power_profile &
  
  # Core system metrics
  probe_battery
  probe_cpu
  probe_cpu_temp
  probe_memory
  probe_disk
  probe_uptime
  probe_audio
  
  # I/O and network metrics (may add slight delay)
  probe_iowait
  probe_network_bandwidth
  probe_disk_io
  probe_network
  probe_top_process
  
  # Wait for background probes to complete
  wait
  
  log_debug "Linux metrics collection complete"
}
