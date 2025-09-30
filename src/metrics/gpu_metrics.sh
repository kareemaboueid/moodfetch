#!/usr/bin/env bash
# GPU metrics collection for moodfetch.
# Uses multiple fallback methods to get GPU info across different systems.

# Holds the discovered GPU tools for later use
GPU_TOOLS=()

# Check which GPU tools are available
discover_gpu_tools() {
  local tools=("nvidia-smi" "intel_gpu_top" "radeontop" "glxinfo" "vainfo")
  
  for tool in "${tools[@]}"; do
    if has_cmd "$tool"; then
      GPU_TOOLS+=("$tool")
      log_debug "Found GPU tool: $tool"
    fi
  done
  
  if [ ${#GPU_TOOLS[@]} -eq 0 ]; then
    log_debug "No GPU tools found, falling back to /sys/class/drm"
  fi
}

# Get GPU temperature using available tools
probe_gpu_temp() {
  local temp=""
  
  # Try NVIDIA first
  if [[ " ${GPU_TOOLS[*]} " =~ " nvidia-smi " ]]; then
    temp=$(try_cmd nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null)
    if [ -n "$temp" ]; then
      log_debug "Got GPU temp from nvidia-smi: ${temp}°C"
      echo "$temp"
      return 0
    fi
  fi
  
  # Try Intel
  if [ -r "/sys/class/drm/card0/device/hwmon/hwmon*/temp1_input" ]; then
    temp=$(try_cmd cat /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input 2>/dev/null)
    if [ -n "$temp" ]; then
      temp=$((temp/1000)) # Convert from millicelsius
      log_debug "Got GPU temp from sysfs: ${temp}°C"
      echo "$temp"
      return 0
    fi
  fi
  
  log_debug "No GPU temperature available"
  echo ""
  return 1
}

# Get GPU utilization percentage
probe_gpu_util() {
  local util=""
  
  # Try NVIDIA
  if [[ " ${GPU_TOOLS[*]} " =~ " nvidia-smi " ]]; then
    util=$(try_cmd nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader | sed 's/ %//')
    if [ -n "$util" ]; then
      log_debug "Got GPU util from nvidia-smi: ${util}%"
      echo "$util"
      return 0
    fi
  fi
  
  # Try Intel (rough estimate from frequency)
  if [ -r "/sys/class/drm/card0/device/gt_cur_freq_mhz" ]; then
    local cur_freq max_freq
    cur_freq=$(try_cmd cat /sys/class/drm/card0/device/gt_cur_freq_mhz)
    max_freq=$(try_cmd cat /sys/class/drm/card0/device/gt_max_freq_mhz)
    if [ -n "$cur_freq" ] && [ -n "$max_freq" ] && [ "$max_freq" -gt 0 ]; then
      util=$((cur_freq * 100 / max_freq))
      log_debug "Got GPU util from freq: ${util}%"
      echo "$util"
      return 0
    fi
  fi
  
  log_debug "No GPU utilization data available"
  echo ""
  return 1
}

# Get GPU memory usage percentage
probe_gpu_memory() {
  local mem_pct=""
  
  # Try NVIDIA
  if [[ " ${GPU_TOOLS[*]} " =~ " nvidia-smi " ]]; then
    local used total
    used=$(try_cmd nvidia-smi --query-gpu=memory.used --format=csv,noheader | sed 's/ MiB//')
    total=$(try_cmd nvidia-smi --query-gpu=memory.total --format=csv,noheader | sed 's/ MiB//')
    if [ -n "$used" ] && [ -n "$total" ] && [ "$total" -gt 0 ]; then
      mem_pct=$((used * 100 / total))
      log_debug "Got GPU memory from nvidia-smi: ${mem_pct}%"
      echo "$mem_pct"
      return 0
    fi
  fi
  
  # Try Intel (if available)
  if [ -r "/sys/class/drm/card0/device/mem_busy_percent" ]; then
    mem_pct=$(try_cmd cat /sys/class/drm/card0/device/mem_busy_percent)
    if [ -n "$mem_pct" ]; then
      log_debug "Got GPU memory from sysfs: ${mem_pct}%"
      echo "$mem_pct"
      return 0
    fi
  fi
  
  log_debug "No GPU memory data available"
  echo ""
  return 1
}