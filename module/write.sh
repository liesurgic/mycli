# set -e enables exit immediately on non-zero exit status
# set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# =============================================================================
# GLOBAL VARIABLES
# =============================================================================
NAME=""
ALIAS=""
DESCRIPTION=""
VERSION=""

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================



# Set global variables from JSON config
set_globals() {
    local json_config="$1"
    
    NAME="$(jq -r '.name // "CLI Tool"' "$json_config")"
    ALIAS="$(jq -r '.alias // .name // "cli"' "$json_config")"
    DESCRIPTION="$(jq -r '.description // "A command line interface"' "$json_config")"
    VERSION="$(jq -r '.version // "1.0.0"' "$json_config")"
}

# =============================================================================
# CONTENT BUILDING FUNCTIONS
# =============================================================================

content_header() {
    cat << EOF
#!/bin/bash

# $NAME CLI
# Generated from config
# $DESCRIPTION

set -e

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

EOF
}

content_footer() {
    cat << EOF

# End of generated CLI
EOF
}

# Build main help content
main_help_content() {
    local json_config="$1"
    
    cat << EOF
# Main help menu - lists all available commands
help() {
    echo "$NAME - $DESCRIPTION"
    echo ""
    echo "Usage: $ALIAS <command> [options]"
    echo ""
    echo "Commands:"
EOF
    
    # Add command listings
    jq -r '.commands[] | "    echo \"  \(.name)    \(.description)\""' "$json_config" 2>/dev/null
    
    cat << EOF
    echo ""
    echo "Run '$ALIAS <command> help' for detailed help on a specific command."
    echo "Run '$ALIAS <command>' to execute a command."
}

EOF
}

# Build individual command help functions
command_help_content() {
    local json_config="$1"
    
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            local cmd_name="$(echo "$command" | jq -r '.name')"
            local cmd_desc="$(echo "$command" | jq -r '.description')"
            
            cat << EOF
# Help for $cmd_name command
${cmd_name}_help() {
    echo "$cmd_name - $cmd_desc"
    echo ""
    echo "Usage: $ALIAS $cmd_name [options]"
    echo ""
EOF
            
            # Add flags if they exist
            local flag_count="$(echo "$command" | jq '.flags | length')"
            if [ "$flag_count" -gt 0 ]; then
                echo "    echo \"Options:\""
                echo "$command" | jq -r '.flags[] | "    echo \"  --\(.name)\(if .shorthand then " (-" + .shorthand + ")" else "" end)    \(.description)\""'
                echo "    echo \"\""
            fi
            
            cat << EOF
    echo "Examples:"
    echo "  $ALIAS $cmd_name"
}

EOF
        fi
    done < <(jq -c '.commands[]' "$json_config")
}

# Build command implementations
content_commands() {
    local json_config="$1"
    
    cat << EOF
# Command implementations

EOF
    
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            local cmd_name="$(echo "$command" | jq -r '.name')"
            
            cat << EOF
${cmd_name}() {
EOF
            
            # Add flag variables
            local flag_index=1
            while IFS= read -r flag_name; do
                if [ -n "$flag_name" ]; then
                    echo "    local ${flag_name}=\"\$$flag_index\""
                    ((flag_index++))
                fi
            done < <(echo "$command" | jq -r '.flags[]?.name // empty')
            
            # Get flag names for display
            local flag_names="$(echo "$command" | jq -r '.flags[]?.name // empty' | tr '\n' ' ' | sed 's/ $//')"
            cat << EOF
    echo "Command '$cmd_name' not yet implemented"
    echo "Available flags: $flag_names"
}

EOF
        fi
    done < <(jq -c '.commands[]' "$json_config")
}

# Build dispatcher logic
content_dispatcher() {
    local json_config="$1"
    
    cat << EOF
# Main dispatcher logic
main() {
    local command="\$1"
    shift

    # Show help if no arguments provided
    if [ \$# -eq 0 ] && [ -z "\$command" ]; then
        help
        exit 0
    fi

    # Route commands
    case "\$command" in
EOF
    
    # Add each command to the case statement
    jq -r '.commands[] | "        \(.name))" + "\n" + "            \(.name) \"$@\"" + "\n" + "            ;;"' "$json_config"
    
    cat << EOF
        help|--help|-h)
            if [ -n "\$1" ]; then
                # Show specific command help
                case "\$1" in
EOF
    
    # Add help for each command
    jq -r '.commands[] | "                    \(.name))" + "\n" + "                        \(.name)_help" + "\n" + "                        ;;"' "$json_config"
    
    cat << EOF
                    *)
                        echo "Unknown command: \$1"
                        echo "Run '$ALIAS help' for available commands."
                        exit 1
                        ;;
                esac
            else
                # Show main help
                help
            fi
            ;;
        *)
            echo "Unknown command: \$command"
            echo "Run '$ALIAS help' for available commands."
            exit 1
            ;;
    esac
}

EOF
}

# =============================================================================
# MAIN CLI GENERATION FUNCTION
# =============================================================================

write_cli() {
    local json_config="$1"
    local filename="$2"

    ensure_jq_installed
    set_globals "$json_config"
    
    # Build the complete CLI file using proper redirection
    {
        content_header
        main_help_content "$json_config"
        command_help_content "$json_config"
        content_commands "$json_config"
        content_dispatcher "$json_config"
        content_footer
    } > "$filename"
    
    chmod +x "$filename"
    print_success "📝 $filename"
}

# =============================================================================
# LEGACY FUNCTIONS (for backward compatibility)
# =============================================================================

# Generate individual command help function
write_command_help_function() {
    local filename="$1"
    local cmd_name="$2"
    local cmd_desc="$3"
    local cli_name="$4"
    
    cat >> "$filename" << EOF

${cmd_name}_help() {
    echo "$cmd_name - $cmd_desc"
    echo ""
    echo "Usage: $cli_name $cmd_name [options]"
    echo ""
EOF
}

# Generate flags section
write_flags_section() {
    local filename="$1"
    local flags="$2"
    
    if [ -n "$flags" ]; then
        echo "    echo \"Options:\"" >> "$filename"
        
        while IFS= read -r flag_b64; do
            if [ -n "$flag_b64" ]; then
                local flag_info="$(extract_flag_info "$flag_b64")"
                local flag_name="$(echo "$flag_info" | cut -d'|' -f1)"
                local flag_shorthand="$(echo "$flag_info" | cut -d'|' -f2)"
                local flag_desc="$(echo "$flag_info" | cut -d'|' -f3)"
                
                if [ -n "$flag_name" ]; then
                    echo "    echo \"$(format_flag_display "$flag_name" "$flag_shorthand")\"" >> "$filename"
                    echo "    echo \"      $flag_desc\"" >> "$filename"
                fi
            fi
        done <<< "$flags"
    fi
}

# Generate examples section
write_examples_section() {
    local filename="$1"
    local cmd_name="$2"
    local flags="$3"
    local cli_name="$4"
    
    echo "    echo \"\"" >> "$filename"
    echo "    echo \"Examples:\"" >> "$filename"
    echo "    echo \"  $cli_name $cmd_name\"" >> "$filename"
    
    # Show examples based on actual flags (limit to first 2 for readability)
    local example_count=0
    if [ -n "$flags" ]; then
        while IFS= read -r flag_b64 && [ $example_count -lt 2 ]; do
            if [ -n "$flag_b64" ]; then
                local flag_info="$(extract_flag_info "$flag_b64")"
                local flag_name="$(echo "$flag_info" | cut -d'|' -f1)"
                local flag_shorthand="$(echo "$flag_info" | cut -d'|' -f2)"
                
                if [ -n "$flag_name" ]; then
                    echo "    echo \"  $cli_name $cmd_name $(format_flag_display "$flag_name" "$flag_shorthand")\"" >> "$filename"
                    ((example_count++))
                fi
            fi
        done <<< "$flags"
    fi
    
    echo "}" >> "$filename"
}

# Format flag display for help output
format_flag_display() {
    local flag_name="$1"
    local flag_shorthand="$2"
    if [ -n "$flag_shorthand" ]; then
        echo "  -$flag_shorthand, --$flag_name"
    else
        echo "  --$flag_name"
    fi
}

# =============================================================================
# EXECUTION
# =============================================================================

# Generate CLI if config file exists
if [ -f "config.json" ]; then
    write_cli "config.json" ".tmp/cli.sh"
else
    print_error "config.json not found"
    exit 1
fi 