#!/usr/bin/env bash
# Lightweight update notifier for moodfetch
# Checks if newer commits are available on GitHub without auto-updating

# Repository information
MOODFETCH_REPO="kareemaboueid/moodfetch"
MOODFETCH_BRANCH="main"

# Get current local commit hash
get_local_commit() {
    if [ -d ".git" ]; then
        git rev-parse HEAD 2>/dev/null
    else
        echo ""
    fi
}

# Get remote commit hash using git ls-remote (preferred method)
get_remote_commit_git() {
    if ! has_cmd git; then
        return 1
    fi
    
    local remote_commit
    remote_commit=$(timeout 1.5s git ls-remote origin "${MOODFETCH_BRANCH}" 2>/dev/null | cut -f1)
    
    if [ -n "${remote_commit}" ]; then
        echo "${remote_commit}"
        return 0
    else
        return 1
    fi
}

# Fallback: Get remote commit hash using GitHub API
get_remote_commit_api() {
    if ! has_cmd curl; then
        return 1
    fi
    
    local api_url="https://api.github.com/repos/${MOODFETCH_REPO}/commits/${MOODFETCH_BRANCH}"
    local response
    response=$(timeout 1.5s curl -s --max-time 1.5 "${api_url}" 2>/dev/null)
    
    if [ -n "${response}" ]; then
        local remote_commit
        remote_commit=$(echo "${response}" | grep -o '"sha": *"[^"]*"' | head -1 | cut -d'"' -f4)
        if [ -n "${remote_commit}" ]; then
            echo "${remote_commit}"
            return 0
        fi
    fi
    
    return 1
}

# Check for updates and show notification if needed
check_for_updates() {
    # Only check if we're in a git repository
    if [ ! -d ".git" ]; then
        log_debug "Not in a git repository, skipping update check"
        return 0
    fi
    
    local local_commit
    local_commit=$(get_local_commit)
    
    if [ -z "${local_commit}" ]; then
        log_debug "Could not determine local commit, skipping update check"
        return 0
    fi
    
    local remote_commit
    
    # Try git ls-remote first (faster and more reliable)
    if remote_commit=$(get_remote_commit_git); then
        log_debug "Got remote commit via git ls-remote: ${remote_commit:0:8}"
    elif remote_commit=$(get_remote_commit_api); then
        log_debug "Got remote commit via GitHub API: ${remote_commit:0:8}"
    else
        log_debug "Could not check for updates (network timeout or unavailable)"
        return 0
    fi
    
    # Compare commits
    if [ "${local_commit}" != "${remote_commit}" ]; then
        # Check if we're actually behind (not just different)
        if has_cmd git && git merge-base --is-ancestor "${local_commit}" "${remote_commit}" 2>/dev/null; then
            show_update_notification
        else
            log_debug "Local commit differs but may not be behind remote"
        fi
    else
        log_debug "Repository is up-to-date"
    fi
}

# Show the update notification
show_update_notification() {
    echo ""
    echo "[!] A new update of moodfetch is available."
    echo "To update, run:"
    
    # Determine the current repository path
    local repo_path
    repo_path=$(pwd)
    
    echo "cd ${repo_path} && git pull && sudo make install"
}