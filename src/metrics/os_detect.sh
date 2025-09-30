#!/usr/bin/env bash
# Linux distribution detection and system interface discovery for moodfetch.
# Identifies Linux distribution and available system interfaces for metrics collection.

# OS family constants
OS_LINUX="linux"
OS_MACOS="macos" 
OS_BSD="bsd"
OS_UNKNOWN="unknown"

# Current detected OS
CURRENT_OS="$OS_UNKNOWN"

# System interface availability flags
HAS_PROCFS=false      # /proc filesystem
HAS_SYSFS=false       # /sys filesystem
HAS_SYSCTL=false      # sysctl interface
HAS_IOREG=false       # macOS ioreg (unused on Linux)
HAS_POWERMETRICS=false # macOS powermetrics (unused on Linux)

# Distribution information
DISTRO_NAME=""       # e.g., "Ubuntu", "Fedora", etc.
DISTRO_VERSION=""    # Distribution version

# Initialize OS detection
init_os_detect() {
    log_debug "Detecting operating system and interfaces..."
    
    # Determine OS family
    case "$(uname -s)" in
        Linux)
            CURRENT_OS="$OS_LINUX"
            detect_linux_interfaces
            ;;
        Darwin)
            CURRENT_OS="$OS_MACOS"
            log_warn "macOS detected but not supported in this version"
            ;;
        FreeBSD|OpenBSD|NetBSD)
            CURRENT_OS="$OS_BSD"
            log_warn "BSD detected but not supported in this version"
            ;;
        *)
            CURRENT_OS="$OS_UNKNOWN"
            log_warn "Unknown operating system: $(uname -s)"
            ;;
    esac
    
    log_debug "Detected OS: $CURRENT_OS"
    
    # Get Linux distribution info if we're on Linux
    if [ "$CURRENT_OS" = "$OS_LINUX" ]; then
        detect_linux_distro
    fi
}

# Detect Linux distribution information
detect_linux_distro() {
    if [ -f "/etc/os-release" ]; then
        # shellcheck source=/dev/null
        . "/etc/os-release"
        DISTRO_NAME="$NAME"
        DISTRO_VERSION="$VERSION_ID"
        log_debug "Detected Linux distribution: $DISTRO_NAME $DISTRO_VERSION"
    else
        DISTRO_NAME="Unknown Linux"
        DISTRO_VERSION="Unknown"
        log_debug "Could not determine Linux distribution"
    fi
}

# Detect available interfaces on Linux
detect_linux_interfaces() {
    log_debug "Detecting Linux system interfaces..."
    
    # Check for procfs
    if [ -d "/proc" ] && [ -r "/proc/cpuinfo" ]; then
        HAS_PROCFS=true
        log_debug "Found Linux procfs"
    else
        log_warn "procfs not available or not readable"
    fi
    
    # Check for sysfs
    if [ -d "/sys" ] && [ -r "/sys/class/power_supply" ]; then
        HAS_SYSFS=true
        log_debug "Found Linux sysfs"
    else
        log_warn "sysfs not available or not readable"
    fi
    
    # Check for sysctl (some Linux systems have it)
    if has_cmd "sysctl"; then
        HAS_SYSCTL=true
        log_debug "Found sysctl on Linux"
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