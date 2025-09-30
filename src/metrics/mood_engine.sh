#!/usr/bin/env bash
# Decides which mood to show, based on metrics and priorities.
# Uses templates.sh for rich, sarcastic messages and utils.sh for rendering.


# If everything is fine/boring, pick a random witty fallback.
random_witty_fallback() {
  local fallbacks=(
    "Existential crisis in progress…"
    "Pretending to be busy while waiting for cron jobs."
    "Dreaming of electric sheep, but stuck with your tabs."
    "Running fine, but spiritually fragmented."
    "Mood stable — unlike your Wi-Fi."
  )
  local size="${#fallbacks[@]}"
  echo "${fallbacks[$((RANDOM % size))]}"
}

# ----- Clean placeholders if verbose flag is disabled -----
strip_placeholders() {
  local text="$1"
  # sed: remove {placeholders}, then collapse multiple spaces to one
  echo "$text" | sed -E 's/\{[a-zA-Z0-9_]+\}//g' | sed 's/  */ /g'
}

# Priority selection similar to your original design, but streamlined:
# 1) Battery critical/low/charging
# 2) CPU hot / pressure
# 3) RAM full
# 4) Disk full / high iowait
# 5) Net offline / Wi-Fi weak (best-effort)
# 6) Power never sleep (skipped unless easily detectable)
# 7) Audio muted
# 8) Default OK
# 10) Random witty fallback

mood_engine_pick() {
  # Set default for verbose flag to prevent undefined variable errors
  local verbose=${verbose:-false}
  local category="" template="" message=""

  # ---- Battery branch ----
  if [ -n "${battery_pct}" ]; then
    if [ "${battery_pct}" -le 12 ]; then
      category="battery_critical_tpl"
    elif [ "${battery_pct}" -le 25 ]; then
      category="battery_low_tpl"
    else
      # check if plugged? we don’t read status text here, keep it simple
      :
    fi
  fi

  # If no battery category yet, check CPU thermals/pressure
  if [ -z "${category}" ]; then
    if [ -n "${cpu_temp}" ] && [ "${cpu_temp}" -ge 88 ]; then
      category="cpu_hot_tpl"
    elif [ -n "${load_per_core}" ] && awk "BEGIN{exit !(${load_per_core} >= 0.90)}"; then
      category="cpu_pressure_tpl"
    elif [ -n "${cpu_util_pct}" ] && [ "${cpu_util_pct}" -ge 92 ]; then
      category="cpu_pressure_tpl"
    fi
  fi

  # RAM pressure
  if [ -z "${category}" ]; then
    if [ -n "${ram_pct}" ] && [ "${ram_pct}" -ge 92 ]; then
      category="ram_full_tpl"
    elif [ -n "${swap_pct}" ] && [ "${swap_pct}" -ge 40 ]; then
      category="ram_full_tpl"
    fi
  fi

  # Disk pressure
  if [ -z "${category}" ]; then
    if [ -n "${disk_pct}" ] && [ "${disk_pct}" -ge 92 ]; then
      category="disk_full_tpl"
    elif [ -n "${iowait_pct}" ] && [ "${iowait_pct}" -ge 20 ]; then
      category="disk_iowait_tpl"
    fi
  fi

  # Net-ish checks (very light best-effort)
  if [ -z "${category}" ]; then
    # if no wifi_signal and iface seems wifi-like, call it weak (very rough)
    if [ -z "${wifi_signal}" ] && printf '%s' "${iface}" | grep -qiE 'wl|wifi|wlan'; then
      category="wifi_weak_tpl"
    fi
  fi

  # Audio muted hint: treat volume 0 as muted (we don’t probe mute flags)
  if [ -z "${category}" ] && [ -n "${volume_pct}" ] && [ "${volume_pct}" -eq 0 ]; then
    category="audio_muted_tpl"
  fi

  # Long-uptime easter egg
  if [ -z "${category}" ] && [ -n "${uptime_h}" ] && [ "${uptime_h}" -ge 72 ]; then
    category="uptime_zombie_tpl"
  fi

  # Network stress check (if significant bandwidth usage)
  if [ -z "${category}" ] && [ -n "${net_rx_bps}" ] && [ -n "${net_tx_bps}" ]; then
    rx_mb="$((net_rx_bps / 1000000))"  # Convert to MB/s
    tx_mb="$((net_tx_bps / 1000000))"
    if [ "$rx_mb" -gt "${CONFIG_NET_HIGH:-50}" ] || [ "$tx_mb" -gt "${CONFIG_NET_HIGH:-50}" ]; then
      category="net_busy_tpl"
    fi
  fi

  # Process overload check
  if [ -z "${category}" ] && [ -n "${process_count}" ] && [ "${process_count}" -gt "${CONFIG_PROC_HIGH:-500}" ]; then
    category="proc_high_tpl"
  fi

  # Default calm
  if [ -z "${category}" ]; then
    category="default_ok_tpl"
  fi

  # Pick a template line from the chosen array
  template="$(random_choice "${category}")"

  # Fill placeholders (numbers) always
  message="$(render_placeholders "${template}")"

  # If for any reason message is empty, use witty fallback
  if [ -z "${message}" ]; then
    message="$(random_witty_fallback)"
  fi

  # Final step: strip placeholders if verbose flag is false
  if ! $verbose; then
    message="$(strip_placeholders "$message")"
  fi

  printf '%s' "${message}"
}
