#!/usr/bin/env bash
# Configuration loader and parser for moodfetch.
# Handles both system-wide (/etc/moodfetch/config) and user (~/.config/moodfetch/config) settings.

# Default configuration values
CONFIG_DEFAULTS=(
  "weather_timeout=1.5"              # Weather API timeout in seconds
  "battery_critical=15"              # Battery critical threshold (%)
  "battery_low=30"                   # Battery low threshold (%)
  "cpu_hot=80"                       # CPU temperature warning (°C)
  "cpu_high_load=75"                 # CPU utilization warning (%)
  "ram_high=85"                      # RAM usage warning (%)
  "disk_high=90"                     # Disk usage warning (%)
)

# Paths for configuration files (in order of precedence)
USER_CONFIG="${HOME}/.config/moodfetch/config"
SYSTEM_CONFIG="/etc/moodfetch/config"

# Load a specific config file if it exists
load_config_file() {
  local config_file="$1"
  local key value

  if [ -r "${config_file}" ]; then
    while IFS='=' read -r key value; do
      # Skip comments and empty lines
      [[ "${key}" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${key}" ]] && continue

      # Trim whitespace
      key="${key// /}"
      value="${value// /}"

      # Export as uppercase env var
      export "CONFIG_${key^^}=${value}"
    done < "${config_file}"
    return 0
  fi
  return 1
}

# Initialize configuration with defaults
init_config() {
  local key value
  
  # First set defaults
  for pair in "${CONFIG_DEFAULTS[@]}"; do
    key="${pair%%=*}"
    value="${pair#*=}"
    export "CONFIG_${key^^}=${value}"
  done

  # Then try loading system-wide config
  load_config_file "${SYSTEM_CONFIG}" || true

  # Finally load user config (overrides system)
  load_config_file "${USER_CONFIG}" || true
}

# Helper to get config value with default fallback
get_config() {
  local key="$1"
  local default="$2"
  local value

  # Try to get from environment (allowing CLI flags to override)
  value="${!key:-}"
  
  # If not found, try config
  if [ -z "${value}" ]; then
    value="${!key:-${default}}"
  fi

  echo "${value}"
}