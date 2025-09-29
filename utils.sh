#!/usr/bin/env bash
# Small, human-friendly helpers for commands, strings, randomness, and placeholders.

set -o pipefail

# Return 0 if the command exists in PATH, 1 otherwise.
has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Run a command safely with timeout-like behavior if available; otherwise best-effort.
run_quiet() {
  "$@" >/dev/null 2>&1
}

# Choose a random element from a bash array passed by name (not values).
random_choice() {
  local arr_name="$1"
  local size
  eval "size=\${#${arr_name}[@]}"
  if [ -z "$size" ] || [ "$size" -eq 0 ]; then
    echo ""
    return
  fi
  local idx=$((RANDOM % size))
  local val
  eval "val=\${${arr_name}[\$idx]}"
  echo "$val"
}

# Replace placeholders in a template string with variables already in the environment.
render_placeholders() {
  local template="$1"
  shift || true

  local keys=(
    battery_pct cpu_temp cpu_util_pct load_per_core ram_pct swap_pct
    disk_pct uptime_h iface wifi_signal top_proc distro kernel hostname profile
    iowait_pct volume_pct
  )
  local out="${template}"

  for k in "${keys[@]}"; do
    # shellcheck disable=SC2154
    local val="${!k}"
    # fallback for empty values → generic "N/A"
    if [ -z "${val}" ]; then
      val="N/A"
    fi

    if [ "${strip_metrics_placeholders:-true}" = true ]; then
      case "${k}" in
        battery_pct) val="low battery" ;;
        cpu_temp) val="high heat" ;;
        cpu_util_pct|load_per_core) val="heavy load" ;;
        ram_pct|swap_pct) val="memory pressure" ;;
        disk_pct) val="disk stress" ;;
        uptime_h) val="long uptime" ;;
        wifi_signal) val="weak signal" ;;
        volume_pct) val="muted" ;;
        iowait_pct) val="I/O lag" ;;
      esac
    fi

    local esc
    esc="$(printf '%s' "${val}" | sed 's/[&/\]/\\&/g')"
    out="$(printf '%s' "${out}" | sed "s/{${k}}/${esc}/g")"
  done

  out="$(printf '%s' "${out}" | sed 's/%%/%/g')"

  local pair key override_val
  for pair in "$@"; do
    key="${pair%%=*}"
    override_val="${pair#*=}"
    local esc2
    esc2="$(printf '%s' "${override_val}" | sed 's/[&/\]/\\&/g')"
    out="$(printf '%s' "${out}" | sed "s/{${key}}/${esc2}/g")"
  done

  printf '%s' "${out}"
}

# Clamp numeric strings into integer percentages [0..100]
to_int_pct() {
  local v="$1"
  case "${v}" in
    ''|*[!0-9.]*)
      echo "0"
      ;;
    *)
      printf '%d' "$(printf '%.0f' "${v}")"
      ;;
  esac
}
