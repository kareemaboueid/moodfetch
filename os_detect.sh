#!/usr/bin/env bash
# Linux distribution detection and system interface discovery for moodfetch.
# Identifies Linux distribution and available system interfaces for metrics collection.

# System interface availability flags
HAS_PROCFS=false      # /proc filesystem
HAS_SYSFS=false      # /sys filesystem

# Distribution information
DISTRO_NAME=""       # e.g., "Ubuntu", "Fedora", etc.
DISTRO_VERSION=""    # Distribution version

# Initialize OS detection
init_os_detect() {
    log_debug "Detecting operating system..."
    
    # Detect OS family first
    case "$(uname -s)" in
        Linux*)
            CURRENT_OS=$OS_LINUX
            detect_linux_interfaces
            ;;
        Darwin*)
            CURRENT_OS=$OS_MACOS
            detect_macos_interfaces
            ;;
        FreeBSD*|OpenBSD*|NetBSD*|DragonFly*)
            CURRENT_OS=$OS_BSD
            detect_bsd_interfaces
            ;;
        *)
            CURRENT_OS=$OS_UNKNOWN
            log_warn "Unknown operating system: $(uname -s)"
            ;;
    esac
    
    log_info "Detected OS: $CURRENT_OS"
}

# Detect available interfaces on Linux
detect_linux_interfaces() {
    # Check for procfs
    if [ -d "/proc" ] && [ -r "/proc/cpuinfo" ]; then
        HAS_PROCFS=true
        log_debug "Found Linux procfs"
    fi
    
    # Check for sysfs
    if [ -d "/sys" ] && [ -r "/sys/class/power_supply" ]; then
        HAS_SYSFS=true
        log_debug "Found Linux sysfs"
    fi
    
    # Check for sysctl (some Linux systems have it)
    if has_cmd "sysctl"; then
        HAS_SYSCTL=true
        log_debug "Found sysctl on Linux"
    fi
}

# Detect available interfaces on macOS
detect_macos_interfaces() {
    # macOS always has sysctl
    HAS_SYSCTL=true
    log_debug "Found macOS sysctl"
    
    # Check for ioreg
    if has_cmd "ioreg"; then
        HAS_IOREG=true
        log_debug "Found macOS ioreg"
    fi
    
    # Check for powermetrics (requires root)
    if has_cmd "powermetrics"; then
        if [ "$(id -u)" -eq 0 ]; then
            HAS_POWERMETRICS=true
            log_debug "Found macOS powermetrics (root access available)"
        else
            log_debug "Found macOS powermetrics (but no root access)"
        fi
    fi
}

# Detect available interfaces on BSD
detect_bsd_interfaces() {
    # BSDs always have sysctl
    HAS_SYSCTL=true
    log_debug "Found BSD sysctl"
    
    # Some BSDs also have limited procfs
    if [ -d "/proc" ] && [ -r "/proc/cpuinfo" ]; then
        HAS_PROCFS=true
        log_debug "Found BSD procfs"
    fi
}

# Public: Check if running on specific OS
is_linux() {
    [ "$CURRENT_OS" = "$OS_LINUX" ]
}

is_macos() {
    [ "$CURRENT_OS" = "$OS_MACOS" ]
}

is_bsd() {
    [ "$CURRENT_OS" = "$OS_BSD" ]
}

# Public: Get current OS family
get_os_family() {
    echo "$CURRENT_OS"
}

# Public: Check for specific interfaces
has_procfs() {
    $HAS_PROCFS
}

has_sysfs() {
    $HAS_SYSFS
}

has_sysctl() {
    $HAS_SYSCTL
}

has_ioreg() {
    $HAS_IOREG
}

has_powermetrics() {
    $HAS_POWERMETRICS
}

# Return appropriate sysctl command for current OS
get_sysctl_cmd() {
    local key="$1"
    case "$CURRENT_OS" in
        $OS_LINUX)
            echo "sysctl -n $key 2>/dev/null"
            ;;
        $OS_MACOS|$OS_BSD)
            echo "sysctl -n $key 2>/dev/null"
            ;;
        *)
            echo "false"  # Fail safely
            ;;
    esac
}

# Safely read sysctl value with fallback
read_sysctl() {
    local key="$1"
    local fallback="$2"
    local cmd
    cmd="$(get_sysctl_cmd "$key")"
    
    if [ "$cmd" = "false" ]; then
        echo "$fallback"
        return 1
    fi
    
    local val
    val="$(eval "$cmd")" || true
    if [ -n "$val" ]; then
        echo "$val"
    else
        echo "$fallback"
        return 1
    fi
}