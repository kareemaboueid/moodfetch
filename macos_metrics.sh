#!/usr/bin/env bash
# macOS-specific metric collection for moodfetch
# Uses native macOS tools: sysctl, ioreg, system_profiler, powermetrics

# Get macOS battery information using ioreg
probe_macos_battery() {
    if ! has_ioreg; then
        return 1
    fi
    
    local bat_info max_cap cur_cap is_charging
    bat_info="$(ioreg -r -c "AppleSmartBattery")"
    
    if [ -z "$bat_info" ]; then
        return 1  # No battery found
    fi
    
    max_cap="$(echo "$bat_info" | awk '/"MaxCapacity"/{print $3}')"
    cur_cap="$(echo "$bat_info" | awk '/"CurrentCapacity"/{print $3}')"
    is_charging="$(echo "$bat_info" | awk '/"IsCharging"/{print $3}')"
    
    if [ -n "$max_cap" ] && [ -n "$cur_cap" ] && [ "$max_cap" -gt 0 ]; then
        battery_pct="$((cur_cap * 100 / max_cap))"
        [ "$is_charging" = "Yes" ] && charging=true || charging=false
    fi
}

# Get CPU information using sysctl and powermetrics
probe_macos_cpu() {
    local cores temp load
    
    # Get number of cores
    cores="$(read_sysctl "hw.ncpu" "1")"
    
    # Get CPU load (1-minute average)
    load="$(read_sysctl "vm.loadavg" "" | awk '{print $2}')"
    if [ -n "$load" ] && [ -n "$cores" ]; then
        load_per_core="$(awk -v l="$load" -v c="$cores" 'BEGIN{printf("%.2f",l/c)}')"
    fi
    
    # Get CPU utilization using powermetrics if available (requires root)
    if has_powermetrics; then
        local util
        util="$(powermetrics -s cpu_power -i 1 -n 1 | grep "CPU Power" | awk '{print $4}')"
        if [ -n "$util" ]; then
            cpu_util_pct="$util"
        fi
    fi
    
    # Get CPU temperature if SMC access is available
    if has_cmd "smckit"; then
        local temp_raw
        temp_raw="$(smckit -r TC0P 2>/dev/null)"
        if [ -n "$temp_raw" ]; then
            cpu_temp="$(printf "%.0f" "$temp_raw")"
        fi
    fi
}

# Get memory information using sysctl and vm_stat
probe_macos_memory() {
    local total_pages free_pages inactive_pages
    local page_size total_bytes used_bytes
    
    # Get page size and counts
    page_size="$(read_sysctl "hw.pagesize" "4096")"
    total_pages="$(read_sysctl "hw.memsize" "" | awk -v ps="$page_size" '{printf("%.0f", $1/ps)}')"
    
    if [ -n "$total_pages" ] && has_cmd "vm_stat"; then
        local vm_stats
        vm_stats="$(vm_stat)"
        free_pages="$(echo "$vm_stats" | awk '/free/{gsub(/\./,"");print $3}')"
        inactive_pages="$(echo "$vm_stats" | awk '/inactive/{gsub(/\./,"");print $3}')"
        
        if [ -n "$free_pages" ] && [ -n "$inactive_pages" ]; then
            total_bytes="$((total_pages * page_size))"
            used_bytes="$(((total_pages - free_pages - inactive_pages) * page_size))"
            ram_pct="$((used_bytes * 100 / total_bytes))"
        fi
    fi
    
    # Get swap usage
    local swap_total swap_used
    swap_total="$(read_sysctl "vm.swapusage" "" | awk -F'[M ]' '/total/{print $3}')"
    swap_used="$(read_sysctl "vm.swapusage" "" | awk -F'[M ]' '/used/{print $7}')"
    if [ -n "$swap_total" ] && [ -n "$swap_used" ] && [ "$swap_total" -gt 0 ]; then
        swap_pct="$((swap_used * 100 / swap_total))"
    fi
}

# Get disk usage for root volume
probe_macos_disk() {
    if has_cmd "df"; then
        local usage
        usage="$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')"
        if [ -n "$usage" ]; then
            disk_pct="$usage"
        fi
    fi
}

# Get disk I/O statistics using iostat
probe_macos_disk_io() {
    if ! has_cmd "iostat"; then
        return 1
    fi
    
    local disk_stats disk_name
    disk_name="$(df / | awk 'NR==2 {print $1}' | sed 's/\/dev\///')"
    
    if [ -n "$disk_name" ]; then
        disk_stats="$(iostat -d -c 2 -w 1 "$disk_name" | tail -n 1)"
        disk_read_bps="$(echo "$disk_stats" | awk '{printf "%.0f", $3 * 512}')"  # Convert to bytes/sec
        disk_write_bps="$(echo "$disk_stats" | awk '{printf "%.0f", $4 * 512}')"
    fi
}

# Get process count
probe_macos_processes() {
    if has_cmd "ps"; then
        process_count="$(ps -A | wc -l | tr -d ' ')"
    fi
}

# Get network interface statistics
probe_macos_network() {
    if ! has_cmd "netstat"; then
        return 1
    fi
    
    # Get primary interface
    local primary_if stats
    primary_if="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"
    
    if [ -n "$primary_if" ]; then
        iface="$primary_if"
        stats="$(netstat -I "$primary_if" -b | tail -n 1)"
        if [ -n "$stats" ]; then
            local bytes_in bytes_out
            bytes_in="$(echo "$stats" | awk '{print $7}')"
            bytes_out="$(echo "$stats" | awk '{print $10}')"
            
            # Get rates over 1 second
            sleep 1
            stats="$(netstat -I "$primary_if" -b | tail -n 1)"
            local bytes_in2 bytes_out2
            bytes_in2="$(echo "$stats" | awk '{print $7}')"
            bytes_out2="$(echo "$stats" | awk '{print $10}')"
            
            net_rx_bps="$((bytes_in2 - bytes_in))"
            net_tx_bps="$((bytes_out2 - bytes_out))"
        fi
    fi
}

# Get Wi-Fi signal strength using airport
probe_macos_wifi() {
    if [ ! -x "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" ]; then
        return 1
    fi
    
    local signal
    signal="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ agrCtlRSSI/{print $2}')"
    if [ -n "$signal" ]; then
        # Convert dBm to percentage (rough approximation)
        # -50 dBm or higher = 100%, -100 dBm or lower = 0%
        if [ "$signal" -ge -50 ]; then
            wifi_signal="100"
        elif [ "$signal" -le -100 ]; then
            wifi_signal="0"
        else
            wifi_signal="$(( (signal + 100) * 2 ))"
        fi
    fi
}

# Get volume information using osascript
probe_macos_volume() {
    if has_cmd "osascript"; then
        local vol
        vol="$(osascript -e 'output volume of (get volume settings)')"
        if [ -n "$vol" ]; then
            volume_pct="$vol"
        fi
    fi
}