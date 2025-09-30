#!/usr/bin/env bash
# Logging and debug support for moodfetch.
# Provides structured logging with different severity levels and debug mode support.

# Log levels (lower number = higher severity)
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_DEBUG=3

# Default to info level unless debug mode is enabled
CURRENT_LOG_LEVEL=${LOG_INFO}

# ANSI color codes for log levels (when color is enabled)
if [ "${CONFIG_COLOR_ENABLED:-true}" = true ] && [ -t 2 ]; then
  COLOR_ERROR='\033[1;31m'    # Bold red
  COLOR_WARN='\033[1;33m'     # Bold yellow
  COLOR_INFO='\033[1;36m'     # Bold cyan
  COLOR_DEBUG='\033[1;35m'    # Bold magenta
  COLOR_RESET='\033[0m'
else
  COLOR_ERROR=""
  COLOR_WARN=""
  COLOR_INFO=""
  COLOR_DEBUG=""
  COLOR_RESET=""
fi

# Enable debug mode
enable_debug() {
  CURRENT_LOG_LEVEL=${LOG_DEBUG}
  log_debug "Debug mode enabled"
}

# Internal: prefix timestamp to log message
_log_prefix() {
  local level="$1"
  printf "[%s] %-5s: " "$(date +%H:%M:%S)" "${level}"
}

# Core logging function
_log() {
  local level="$1"
  local color="$2"
  local msg="$3"
  local prefix

  # Check if we should show this message based on current log level
  if [ "${level}" -gt "${CURRENT_LOG_LEVEL}" ]; then
    return 0
  fi

  # Build the prefix with timestamp and level
  case "${level}" in
    ${LOG_ERROR}) prefix="$(_log_prefix "ERROR")" ;;
    ${LOG_WARN})  prefix="$(_log_prefix "WARN")" ;;
    ${LOG_INFO})  prefix="$(_log_prefix "INFO")" ;;
    ${LOG_DEBUG}) prefix="$(_log_prefix "DEBUG")" ;;
    *) prefix="$(_log_prefix "?????")" ;;
  esac

  # Print to stderr with optional color
  printf "%s%s%s%s\n" "${color}" "${prefix}" "${msg}" "${COLOR_RESET}" >&2
}

# Public logging functions
log_error() { _log ${LOG_ERROR} "${COLOR_ERROR}" "$*"; }
log_warn()  { _log ${LOG_WARN}  "${COLOR_WARN}"  "$*"; }
log_info()  { _log ${LOG_INFO}  "${COLOR_INFO}"  "$*"; }
log_debug() { _log ${LOG_DEBUG} "${COLOR_DEBUG}" "$*"; }

# Error handling helper that logs and exits
die() {
  log_error "$*"
  exit 1
}

# Try running a command, log on failure
try_cmd() {
  local cmd="$*"
  log_debug "Executing: ${cmd}"
  
  if ! output=$("$@" 2>&1); then
    log_error "Command failed: ${cmd}"
    log_error "Output: ${output}"
    return 1
  fi
  
  log_debug "Command succeeded: ${cmd}"
  printf "%s" "${output}"
  return 0
}