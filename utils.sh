#!/usr/bin/env bash
# Small, human-friendly helpers for commands, strings, randomness, and placeholders.

set -o pipefail

# Return 0 if the command exists in PATH, 1 otherwise.
has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Run a command safely with timeout-like behavior if available; otherwise best-effort.
run_quiet() {
  # usage: run_quiet <cmd ...>
  # we don’t spam the terminal—errors are swallowed unless needed elsewhere
  "$@" >/dev/null 2>&1
}

# Choose a random element from a bash array passed by name (not values).
# usage: random_choice array_name
random_choice() {
  local arr_name="$1"
  # Count elements in array by name
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
# Supported placeholders are like {battery_pct}, {cpu_temp}, etc.
render_placeholders() {
  local template="$1"
  shift || true

  # We accept additional "key=value" overrides via arguments
  # but primary source of truth is exported variables from metrics.sh

  # Gather all known placeholders → we’ll replace them if env var exists
  local keys=(
    battery_pct cpu_temp cpu_util_pct load_per_core ram_pct swap_pct
    disk_pct uptime_h iface wifi_signal top_proc distro kernel hostname profile
    iowait_pct volume_pct gpu_model
  )
  local out="${template}"

  # Replace each known placeholder with its env value if set (else 0 or empty)
  for k in "${keys[@]}"; do
    # shellcheck disable=SC2154
    local val="${!k}"
    # Default some unset values to 0 to avoid showing {placeholder}
    if [ -z "${val}" ]; then
      case "${k}" in
        battery_pct|cpu_util_pct|ram_pct|swap_pct|disk_pct|iowait_pct|uptime_h|wifi_signal|volume_pct)
          val="0"
          ;;
        *)
          val=""
          ;;
      esac
    fi
    # Escape forward slashes for sed
    local esc
    esc="$(printf '%s' "${val}" | sed 's/[&/\]/\\&/g')"
    out="$(printf '%s' "${out}" | sed "s/{${k}}/${esc}/g")"
  done

  # Convert doubled percent signs "%%" in templates to single "%" for display niceness
  out="$(printf '%s' "${out}" | sed 's/%%/%/g')"

  # If the caller supplied extra overrides as k=v args, apply them last
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

# Tiny helper to clamp numeric strings into integer percentages [0..100]
to_int_pct() {
  local v="$1"
  case "${v}" in
    ''|*[!0-9.]*)
      echo "0"
      ;;
    *)
      # strip decimals
      printf '%d' "$(printf '%.0f' "${v}")"
      ;;
  esac
}
