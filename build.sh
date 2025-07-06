#!/opt/homebrew/bin/bash

# set -e enables exit immediately on non-zero exit status
# set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

build_header() {
    cat << EOF
#!/opt/homebrew/bin/bash

# $NAME CLI
# Generated from config
# $DESCRIPTION

set -e

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "\$SCRIPT_DIR/utils.sh"

EOF
}

build_commands_source() {
    cat << EOF
source "\$SCRIPT_DIR/${NAME}.sh"

EOF
}

build_footer() {
    cat << EOF

# End of generated CLI
EOF
}

# Build main help content
build_help() {
    set_globals $1
    
    cat << EOF
# Main help menu - lists all available commands
help() {
    echo "$NAME - $DESCRIPTION"
    echo ""
    echo "Usage: $NAME <command> [options]"
    echo ""
    echo "Commands:"
EOF
    
    # Add command listings
    jq -r '.commands[] | "    echo \"  \(.name)    \(.description)\""' "$JSON_CONFIG" 2>/dev/null
    
    cat << EOF
    echo ""
    echo "Run '$NAME <command> help' for detailed help on a specific command."
    echo "Run '$NAME <command>' to execute a command."
}

EOF
}

# Build individual command help functions
build_cmds_help() {
    set_globals "$1"
    
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            local cmd_name="$(echo "$command" | jq -r '.name')"
            local cmd_desc="$(echo "$command" | jq -r '.description')"
            
            cat << EOF
# Help for $cmd_name command
${cmd_name}_help() {
    echo "$cmd_name - $cmd_desc"
    echo ""
    echo "Usage: $NAME $cmd_name [options]"
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
    echo "  $NAME $cmd_name"
}

EOF
        fi
    done < <(jq -c '.commands[]' "$JSON_CONFIG")
}

# Build command implementations
build_cmds() {
    set_globals "$1"
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
    done < <(jq -c '.commands[]' "$JSON_CONFIG")
}

# Build dispatcher logic
build_dispatcher() {
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

    # Check for help subcommand (e.g., "init help", "package help")
    if [ "\$1" = "help" ]; then
        case "\$command" in
EOF
    
    # Add help for each command
    jq -r '.commands[] | "            \(.name))" + "\n" + "                \(.name)_help" + "\n" + "                exit 0" + "\n" + "                ;;"' "$JSON_CONFIG"
    
    cat << EOF
            *)
                echo "Unknown command: \$command"
                echo "Run '$NAME help' for available commands."
                exit 1
                ;;
        esac
    fi

    # Route commands
    case "\$command" in
EOF
    
    # Add each command to the case statement
    jq -r '.commands[] | "        \(.name))" + "\n" + "            \(.name) \"$@\"" + "\n" + "            ;;"' "$JSON_CONFIG"
    
    cat << EOF
        help|--help|-h)
            if [ -n "\$1" ]; then
                # Show specific command help
                case "\$1" in
EOF
    
    # Add help for each command
    jq -r '.commands[] | "                    \(.name))" + "\n" + "                        \(.name)_help" + "\n" + "                        ;;"' "$JSON_CONFIG"
    
    cat << EOF
                    *)
                        echo "Unknown command: \$1"
                        echo "Run '$NAME help' for available commands."
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
            echo "Run '$NAME help' for available commands."
            exit 1
            ;;
    esac
}

EOF
}

# =============================================================================
# MAIN CLI GENERATION FUNCTION
# =============================================================================

build() {
    local entry_point_script="./${MODULE_NAME}/${ENTRY_POINT_SCRIPT_NAME}"
    local command_script="./${MODULE_NAME}/${MODULE_COMMAND_SCRIPT_NAME}"

    {
        build_header
        build_commands_source
        build_help
        build_cmds_help
        build_dispatcher
        build_footer
        echo 'main "$@"'
    } > "$entry_point_script"

    {
        build_header
        build_cmds
        build_footer
    } > "${command_script}"

    chmod +x "$entry_point_script"
    chmod +x "$command_script"
    
    print_success "Built ${MODULE_NAME} ${ENTRY_POINT_SCRIPT_NAME}" "✏️"
    print_success "Built ${MODULE_NAME} ${MODULE_COMMAND_SCRIPT_NAME}" "✏️"
}

# =============================================================================
# EXECUTION
# =============================================================================

if entry_point "$1"; then
    build
    exit 0
else
    exit 1
fi