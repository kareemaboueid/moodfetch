#!/usr/bin/env bash
# Version management and update checking for moodfetch

# Current version of moodfetch
MOODFETCH_VERSION="0.4.3"
MOODFETCH_REPO="kareemaboueid/moodfetch"

# Parse version string into components
# Returns: array of version components
parse_version() {
    local version="$1"
    local IFS="."
    read -ra version_parts <<< "${version#v}"
    echo "${version_parts[@]}"
}

# Compare two version strings
# Returns: 
#   -1 if version1 < version2
#    0 if version1 = version2
#    1 if version1 > version2
compare_versions() {
    local v1=($1)
    local v2=($2)
    
    # Compare each version component
    for i in {0..2}; do
        local num1=${v1[$i]:-0}
        local num2=${v2[$i]:-0}
        
        if [ "$num1" -lt "$num2" ]; then
            echo "-1"
            return
        elif [ "$num1" -gt "$num2" ]; then
            echo "1"
            return
        fi
    done
    
    # Versions are equal
    echo "0"
}

# Check for updates using GitHub API
check_for_updates() {
    if ! has_cmd "curl"; then
        log_error "curl is required for update checking"
        return 1
    }

    log_debug "Checking for updates..."
    
    # Get latest release from GitHub API
    local api_url="https://api.github.com/repos/${MOODFETCH_REPO}/releases/latest"
    local response
    response=$(curl -s --max-time 5 "$api_url")
    
    if [ -z "$response" ]; then
        log_error "Failed to check for updates"
        return 1
    }
    
    # Extract version from response (assuming tag_name format like "v1.2.3")
    local latest_version
    latest_version=$(echo "$response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$latest_version" ]; then
        log_error "Failed to parse latest version"
        return 1
    }
    
    # Compare versions
    local current_parts
    local latest_parts
    current_parts=($(parse_version "${MOODFETCH_VERSION}"))
    latest_parts=($(parse_version "${latest_version}"))
    
    local comparison
    comparison=$(compare_versions "${current_parts[*]}" "${latest_parts[*]}")
    
    case "$comparison" in
        "-1")
            log_info "New version available: ${latest_version} (current: ${MOODFETCH_VERSION})"
            return 0
            ;;
        "0")
            log_info "You are running the latest version (${MOODFETCH_VERSION})"
            return 0
            ;;
        "1")
            log_info "You are running a development version (${MOODFETCH_VERSION})"
            return 0
            ;;
    esac
}

# Print current version
print_version() {
    echo "moodfetch version ${MOODFETCH_VERSION}"
    echo "Copyright (c) 2025 Kareem Aboueid"
    echo "Licensed under MIT License"
}