#!/usr/bin/env bash
# Decides which mood to show, based on metrics and priorities.
# Uses templates.sh for rich, sarcastic messages and utils.sh for rendering.

# Weather: best-effort via ipinfo + wttr.in (kept here so it’s easy to disable if offline)
get_weather_mood_line() {
  # quick exit if curl not available
  if ! has_cmd curl; then
    return 1
  fi

  # NOTE: Added --max-time 1.5s to avoid slow hangs, fail silently if too slow
  local city cond temp
  city="$(curl -s --max-time 1.5 ipinfo.io/city 2>/dev/null)"
  cond="$(curl -s --max-time 1.5 "https://wttr.in?format=%C" 2>/dev/null)"
  temp="$(curl -s --max-time 1.5 "https://wttr.in?format=%t" 2>/dev/null)"

  # Require at least condition; city/temp are nice-to-have
  if [ -z "${cond}" ]; then
    # fast exit: don’t block mood if weather fails or it's gonna be slow as hell!
    return 1
  fi

  # Simplified categorization
  case "${cond}" in
    *Sunny*|*Clear* )
      printf 'In %s, it is %s %s — my circuits are jealous.' "${city:-somewhere}" "${cond}" "${temp:-}"
      ;;
    *Rain*|*Drizzle* )
      printf 'In %s, it is %s %s — glad I am indoors, unlike your socks.' "${city:-outside}" "${cond}" "${temp:-}"
      ;;
    *Cloud*|*Overcast* )
      printf 'In %s, it is %s %s — gray skies, gray processes.' "${city:-your area}" "${cond}" "${temp:-}"
      ;;
    *Snow*|*Sleet* )
      printf 'In %s, it is %s %s — frozen bits, but still moving.' "${city:-Narnia}" "${cond}" "${temp:-}"
      ;;
    * )
      printf 'In %s, it is %s %s — weather and systems both moody.' "${city:-somewhere}" "${cond}" "${temp:-}"
      ;;
  esac
  return 0
}

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
# 9) Weather mood as an extra flavor if nothing critical happened
# 10) Random witty fallback

mood_engine_pick() {
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

  # Default calm
  if [ -z "${category}" ]; then
    category="default_ok_tpl"
  fi

  # Pick a template line from the chosen array
  template="$(random_choice "${category}")"

  # Fill placeholders (numbers) always
  message="$(render_placeholders "${template}")"

  # If we landed on "default_ok", try to spice with weather; if weather fails, we’re still good.
  if [ "${category}" = "default_ok_tpl" ]; then
    local weather_line
    if weather_line="$(get_weather_mood_line)"; then
      message="${weather_line}"
    fi
  fi

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
