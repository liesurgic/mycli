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

write_content() {
    local content="$1"
    local file="$2"
    printf "%s" "$content" > "$file"
}

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
    local content=""
    content+="#!/bin/bash\n"
    content+="\n"
    content+="# $NAME CLI\n"
    content+="# Generated from config\n"
    content+="# $DESCRIPTION\n"
    content+="\n"
    content+="set -e\n"
    content+="\n"
    content+="# Get the directory where this script is located\n"
    content+="SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"\n"
    content+="\n"
    printf "%s" "$content"
}

content_footer() {
    local content=""
    content+="\n"
    content+="# End of generated CLI\n"
    printf "%s" "$content"
}

# Build main help content
main_help_content() {
    local json_config="$1"
    local content=""
    content+="# Main help menu - lists all available commands\n"
    content+="help() {\n"
    content+="    echo \"$NAME - $DESCRIPTION\"\n"
    content+="    echo \"\"\n"
    content+="    echo \"Usage: $ALIAS <command> [options]\"\n"
    content+="    echo \"\"\n"
    content+="    echo \"Commands:\"\n"
    
    # Add command listings - properly handle command substitution
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            content+="$line\n"
        fi
    done < <(jq -r '.commands[] | "    echo \"  \(.name)    \(.description)\""' "$json_config" 2>/dev/null)
    
    content+="    echo \"\"\n"
    content+="    echo \"Run '$ALIAS <command> help' for detailed help on a specific command.\"\n"
    content+="    echo \"Run '$ALIAS <command>' to execute a command.\"\n"
    content+="}\n"
    content+="\n"
    
    printf "%s" "$content"
}

# Build individual command help functions
command_help_content() {
    local json_config="$1"
    local content=""
    
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            local cmd_name="$(echo "$command" | jq -r '.name')"
            local cmd_desc="$(echo "$command" | jq -r '.description')"
            
            content+="# Help for $cmd_name command\n"
            content+="${cmd_name}_help() {\n"
            content+="    echo \"$cmd_name - $cmd_desc\"\n"
            content+="    echo \"\"\n"
            content+="    echo \"Usage: $ALIAS $cmd_name [options]\"\n"
            content+="    echo \"\"\n"
            
            # Add flags if they exist
            local flag_count="$(echo "$command" | jq '.flags | length')"
            if [ "$flag_count" -gt 0 ]; then
                content+="    echo \"Options:\"\n"
                while IFS= read -r flag_line; do
                    if [ -n "$flag_line" ]; then
                        content+="$flag_line\n"
                    fi
                done < <(echo "$command" | jq -r '.flags[] | "    echo \"  --\(.name)\(if .shorthand then " (-" + .shorthand + ")" else "" end)    \(.description)\""')
                content+="    echo \"\"\n"
            fi
            
            content+="    echo \"Examples:\"\n"
            content+="    echo \"  $ALIAS $cmd_name\"\n"
            content+="}\n"
            content+="\n"
        fi
    done < <(jq -c '.commands[]' "$json_config")
    
    printf "%s" "$content"
}

# Build command implementations
content_commands() {
    local json_config="$1"
    local content=""
    
    content+="# Command implementations\n"
    content+="\n"
    
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            local cmd_name="$(echo "$command" | jq -r '.name')"
            
            content+="${cmd_name}() {\n"
            
            # Add flag variables
            local flag_index=1
            while IFS= read -r flag_name; do
                if [ -n "$flag_name" ]; then
                    content+="    local ${flag_name}=\"\$$flag_index\"\n"
                    ((flag_index++))
                fi
            done < <(echo "$command" | jq -r '.flags[]?.name // empty')
            
            # Get flag names for display
            local flag_names="$(echo "$command" | jq -r '.flags[]?.name // empty' | tr '\n' ' ' | sed 's/ $//')"
            content+="    echo \"Command '$cmd_name' not yet implemented\"\n"
            content+="    echo \"Available flags: $flag_names\"\n"
            content+="}\n"
            content+="\n"
        fi
    done < <(jq -c '.commands[]' "$json_config")
    
    printf "%s" "$content"
}

# Build dispatcher logic
content_dispatcher() {
    local json_config="$1"
    local content=""
    
    content+="# Main dispatcher logic\n"
    content+="main() {\n"
    content+="    local command=\"\$1\"\n"
    content+="    shift\n"
    content+="\n"
    content+="    # Show help if no arguments provided\n"
    content+="    if [ \$# -eq 0 ] && [ -z \"\$command\" ]; then\n"
    content+="        help\n"
    content+="        exit 0\n"
    content+="    fi\n"
    content+="\n"
    content+="    # Route commands\n"
    content+="    case \"\$command\" in\n"
    
    # Add each command to the case statement
    while IFS= read -r case_line; do
        if [ -n "$case_line" ]; then
            content+="$case_line\n"
        fi
    done < <(jq -r '.commands[] | "        \(.name))" + "\n" + "            \(.name) \"$@\"" + "\n" + "            ;;"' "$json_config")
    
    content+="        help|--help|-h)\n"
    content+="            if [ -n \"\$1\" ]; then\n"
    content+="                # Show specific command help\n"
    content+="                case \"\$1\" in\n"
    
    # Add help for each command
    while IFS= read -r help_case_line; do
        if [ -n "$help_case_line" ]; then
            content+="$help_case_line\n"
        fi
    done < <(jq -r '.commands[] | "                    \(.name))" + "\n" + "                        \(.name)_help" + "\n" + "                        ;;"' "$json_config")
    
    content+="                    *)\n"
    content+="                        echo \"Unknown command: \$1\"\n"
    content+="                        echo \"Run '$ALIAS help' for available commands.\"\n"
    content+="                        exit 1\n"
    content+="                        ;;\n"
    content+="                esac\n"
    content+="            else\n"
    content+="                # Show main help\n"
    content+="                help\n"
    content+="            fi\n"
    content+="            ;;\n"
    content+="        *)\n"
    content+="            echo \"Unknown command: \$command\"\n"
    content+="            echo \"Run '$ALIAS help' for available commands.\"\n"
    content+="            exit 1\n"
    content+="            ;;\n"
    content+="    esac\n"
    content+="}\n"
    content+="\n"
    
    printf "%s" "$content"
}

# =============================================================================
# MAIN CLI GENERATION FUNCTION
# =============================================================================

write_cli() {
    local json_config="$1"
    local filename="$2"
    local content=""

    ensure_jq_installed
    set_globals "$json_config"
    
    content+="$(content_header)"
    content+="$(main_help_content "$json_config")"
    content+="$(command_help_content "$json_config")"
    content+="$(content_commands "$json_config")"
    content+="$(content_dispatcher "$json_config")"
    content+="$(content_footer)"
    
    write_content "$content" "$filename"
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