#!/usr/bin/env bash
# Signal handling and cleanup for moodfetch
# Provides graceful shutdown and cleanup on signal reception

# List of temporary files to clean up
declare -a TEMP_FILES=()

# List of background processes to terminate
declare -a BG_PROCS=()

# Cleanup function - called on exit
cleanup() {
    local exit_code=$?
    log_debug "Starting cleanup (exit code: ${exit_code})"
    
    # Kill any remaining background processes
    for pid in "${BG_PROCS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            log_debug "Terminating background process: $pid"
            kill -TERM "$pid" 2>/dev/null || true
        fi
    done
    
    # Remove temporary files
    for file in "${TEMP_FILES[@]}"; do
        if [ -f "$file" ]; then
            log_debug "Removing temporary file: $file"
            rm -f "$file" 2>/dev/null || true
        fi
    done
    
    # Final cleanup messages based on exit code
    if [ $exit_code -eq 0 ]; then
        log_debug "Clean shutdown completed"
    else
        log_warn "Aborted with exit code ${exit_code}"
    fi
    
    exit "$exit_code"
}

# Register a temporary file for cleanup
register_temp_file() {
    local file="$1"
    TEMP_FILES+=("$file")
    log_debug "Registered temporary file for cleanup: $file"
}

# Register a background process for cleanup
register_bg_process() {
    local pid="$1"
    BG_PROCS+=("$pid")
    log_debug "Registered background process for cleanup: $pid"
}

# Initialize signal handlers
init_signal_handlers() {
    log_debug "Initializing signal handlers"
    
    # Set up trap for cleanup on exit
    trap cleanup EXIT
    
    # Handle interrupt (Ctrl+C)
    trap 'log_info "Received interrupt signal"; exit 130' INT
    
    # Handle termination
    trap 'log_info "Received termination signal"; exit 143' TERM
    
    # Handle hangup (terminal closed)
    trap 'log_info "Received hangup signal"; exit 129' HUP
    
    # Ignore SIGPIPE to prevent premature exit on broken pipes
    trap '' PIPE
    
    log_debug "Signal handlers initialized"
}

# Create a temporary file with automatic cleanup
create_temp_file() {
    local template="${1:-moodfetch.XXXXXX}"
    local temp_dir="${TMPDIR:-/tmp}"
    local temp_file
    
    temp_file=$(mktemp "${temp_dir}/${template}") || {
        log_error "Failed to create temporary file"
        return 1
    }
    
    register_temp_file "$temp_file"
    echo "$temp_file"
}

# Run a command in the background with proper cleanup
run_bg_command() {
    local cmd="$*"
    
    # Start the command in background
    eval "$cmd" &
    local pid=$!
    
    # Register for cleanup
    register_bg_process "$pid"
    
    # Return the PID
    echo "$pid"
}