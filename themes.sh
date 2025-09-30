#!/usr/bin/env bash
# Theme system for moodfetch
# Manages different mood personalities and theme loading

# Theme locations in order of precedence
THEME_LOCATIONS=(
    "${HOME}/.config/moodfetch/themes"      # User themes
    "/etc/moodfetch/themes"                 # System-wide themes
    "${script_dir}/themes"                  # Built-in themes
)

# Current theme name (from config)
CURRENT_THEME="$(get_config CONFIG_THEME "sarcastic")"

# Mood template arrays for the current theme
declare -A THEME_TEMPLATES

# Load the specified theme
load_theme() {
    local theme_name="$1"
    local theme_file=""
    
    log_debug "Loading theme: ${theme_name}"
    
    # Search for theme file in theme locations
    for dir in "${THEME_LOCATIONS[@]}"; do
        if [ -r "${dir}/${theme_name}.theme" ]; then
            theme_file="${dir}/${theme_name}.theme"
            break
        fi
    done
    
    # Fall back to sarcastic if theme not found
    if [ -z "$theme_file" ]; then
        if [ "$theme_name" != "sarcastic" ]; then
            log_warn "Theme '${theme_name}' not found, falling back to sarcastic"
            load_theme "sarcastic"
            return
        fi
        # If sarcastic theme is missing, use built-in defaults
        return
    fi
    
    log_debug "Loading theme file: ${theme_file}"
    
    # Reset template arrays
    unset THEME_TEMPLATES
    declare -gA THEME_TEMPLATES
    
    # Parse theme file
    local current_template=""
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Check for template section marker
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            current_template="${BASH_REMATCH[1]}"
            THEME_TEMPLATES["$current_template"]=""
            continue
        fi
        
        # Add line to current template if we're in a section
        if [ -n "$current_template" ]; then
            if [ -z "${THEME_TEMPLATES[$current_template]}" ]; then
                THEME_TEMPLATES["$current_template"]="$line"
            else
                THEME_TEMPLATES["$current_template"]+="|$line"
            fi
        fi
    done < "$theme_file"
    
    log_debug "Loaded ${#THEME_TEMPLATES[@]} template sections"
}

# Get a random line from a template section
get_theme_template() {
    local template_name="$1"
    local templates="${THEME_TEMPLATES[$template_name]:-}"
    
    if [ -z "$templates" ]; then
        log_warn "No templates found for '${template_name}', using default"
        return 1
    fi
    
    # Split on | and get random line
    local IFS="|"
    local lines=($templates)
    local count=${#lines[@]}
    local idx=$((RANDOM % count))
    echo "${lines[$idx]}"
}

# Initialize theme system
init_themes() {
    # Create theme directories if they don't exist
    for dir in "${THEME_LOCATIONS[@]}"; do
        [ ! -d "$dir" ] && mkdir -p "$dir" 2>/dev/null || true
    done
    
    # Load configured theme
    load_theme "$CURRENT_THEME"
}

# List available themes
list_themes() {
    local themes=()
    
    # Collect unique theme names from all locations
    for dir in "${THEME_LOCATIONS[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' file; do
                themes+=("$(basename "$file" .theme)")
            done < <(find "$dir" -maxdepth 1 -name "*.theme" -print0)
        fi
    done
    
    # Sort and remove duplicates
    printf "%s\n" "${themes[@]}" | sort -u
}

# Create a new theme from the current templates
create_theme() {
    local name="$1"
    local output_dir="${HOME}/.config/moodfetch/themes"
    local output_file="${output_dir}/${name}.theme"
    
    # Create theme directory if it doesn't exist
    mkdir -p "$output_dir" || return 1
    
    # Don't overwrite existing themes without confirmation
    if [ -f "$output_file" ]; then
        log_error "Theme '${name}' already exists"
        return 1
    fi
    
    # Create theme file with current templates
    {
        echo "# Moodfetch theme: ${name}"
        echo "# Created: $(date)"
        echo ""
        
        for template in "${!THEME_TEMPLATES[@]}"; do
            echo "[$template]"
            echo "${THEME_TEMPLATES[$template]}" | tr '|' '\n'
            echo ""
        done
    } > "$output_file"
    
    log_info "Created theme: ${output_file}"
    return 0
}