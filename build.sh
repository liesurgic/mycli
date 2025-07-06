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
    echo "Usage: $NAME $cmd_name [options] [args]"
    echo ""
EOF
            
            # Add flags if they exist
            local flag_count="$(echo "$command" | jq '.flags | length')"
            if [ "$flag_count" -gt 0 ]; then
                echo "    echo \"Flags:\""
                echo "$command" | jq -r '.flags[] | "    echo \"  --\(.name)\(if .shorthand then " (-" + .shorthand + ")" else "" end)    \(.description)\""'
                echo "    echo \"\""
            fi
            
            # Add kwargs if they exist
            local kwarg_count="$(echo "$command" | jq '.kwargs | length')"
            if [ "$kwarg_count" -gt 0 ]; then
                echo "    echo \"Options:\""
                echo "$command" | jq -r '.kwargs[] | "    echo \"  --\(.name)=VALUE\(if .shorthand then " (-" + .shorthand + "=VALUE)" else "" end)    \(.description)\""'
                echo "    echo \"\""
            fi
            
            # Add args if they exist
            local arg_count="$(echo "$command" | jq '.args | length')"
            if [ "$arg_count" -gt 0 ]; then
                echo "    echo \"Arguments:\""
                echo "$command" | jq -r '.args[] | "    echo \"  \(.name)    \(.description)\""'
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
    # Parse arguments
    local args=()
    local flags=()
    local kwargs=()
    
    # Parse command line arguments
    while [[ \$# -gt 0 ]]; do
        case \$1 in
EOF
            
            # Add flag parsing
            echo "$command" | jq -r '.flags[]? | "            --\(.name)|-\(.shorthand))" + "\n" + "                flags+=(\"\(.name)\")" + "\n" + "                ;;"'
            
            # Add kwarg parsing
            echo "$command" | jq -r '.kwargs[]? | "            --\(.name)=*|-\(.shorthand)=*)" + "\n" + "                kwargs+=(\"\(.name)=\"$2)" + "\n" + "                shift" + "\n" + "                ;;"'
            
            cat << EOF
            -*)
                echo "Unknown option: \$1"
                ${cmd_name}_help
                exit 1
                ;;
            *)
                args+=("\$1")
                ;;
        esac
        shift
    done
    
    # Set default values for flags
EOF
            
            # Set default values for flags
            echo "$command" | jq -r '.flags[]? | "    local \(.name)=false"'
            
            # Set default values for kwargs
            echo "$command" | jq -r '.kwargs[]? | "    local \(.name)=\"\(.default // "")\""'
            
            # Set default values for args
            echo "$command" | jq -r '.args[]? | "    local \(.name)=\"\(.default // "")\""'
            
            cat << EOF
    
    # Process flags
EOF
            
            # Process flags
            echo "$command" | jq -r '.flags[]? | "    if [[ \" ${flags[@]} \" =~ \" \(.name) \" ]]; then" + "\n" + "        \(.name)=true" + "\n" + "    fi"'
            
            cat << EOF
    
    # Process kwargs
EOF
            
            # Process kwargs
            echo "$command" | jq -r '.kwargs[]? | "    for kwarg in \"${kwargs[@]}\"; do" + "\n" + "        if [[ $kwarg == \(.name)=* ]]; then" + "\n" + "            \(.name)=\"${kwarg#\(.name)=}\"" + "\n" + "        fi" + "\n" + "    done"'
            
            cat << EOF
    
    # Process args
EOF
            
            # Process args
            local arg_index=0
            while IFS= read -r arg_name; do
                if [ -n "$arg_name" ]; then
                    echo "    if [ \${#args[@]} -gt $arg_index ]; then"
                    echo "        $arg_name=\"\${args[$arg_index]}\""
                    echo "    fi"
                    ((arg_index++))
                fi
            done < <(echo "$command" | jq -r '.args[]?.name // empty')
            
            cat << EOF
    
    # Validate required arguments
EOF
            
            # Validate required kwargs
            echo "$command" | jq -r '.kwargs[]? | select(.required == true) | "    if [ -z \"$\(.name)\" ]; then" + "\n" + "        echo \"Error: --\(.name) is required\"" + "\n" + "        '${cmd_name}'_help" + "\n" + "        exit 1" + "\n" + "    fi"'
            
            # Validate required args
            echo "$command" | jq -r '.args[]? | select(.required == true) | "    if [ -z \"$\(.name)\" ]; then" + "\n" + "        echo \"Error: \(.name) argument is required\"" + "\n" + "        '${cmd_name}'_help" + "\n" + "        exit 1" + "\n" + "    fi"'
            
            cat << EOF
    
    # Command implementation
    echo "Command '$cmd_name' not yet implemented"
    echo "Flags: \${flags[@]}"
    echo "Kwargs: \${kwargs[@]}"
    echo "Args: \${args[@]}"
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
    
    # Add each command to the case statement with argument parsing
    while IFS= read -r command; do
        if [ -n "$command" ]; then
            local cmd_name="$(echo "$command" | jq -r '.name')"
            echo "        $cmd_name)"
            echo "            # Parse arguments for $cmd_name"
            echo "            local args=()"
            echo "            local flags=()"
            echo "            local kwargs=()"
            echo "            "
            echo "            # Parse command line arguments"
            echo "            while [[ \$# -gt 0 ]]; do"
            echo "                case \$1 in"
            
            # Add flag parsing
            echo "$command" | jq -r '.flags[]? | "                    --\(.name)|-\(.shorthand))" + "\n" + "                        flags+=(\"\(.name)\")" + "\n" + "                        ;;"'
            
            # Add kwarg parsing
            echo "$command" | jq -r '.kwargs[]? | "                    --\(.name)=*|-\(.shorthand)=*)" + "\n" + "                        kwargs+=(\"\(.name)=\"${1#*=})" + "\n" + "                        ;;"'
            
            echo "                    -*)"
            echo "                        echo \"Unknown option: \$1\""
            echo "                        ${cmd_name}_help"
            echo "                        exit 1"
            echo "                        ;;"
            echo "                    *)"
            echo "                        args+=(\"\$1\")"
            echo "                        ;;"
            echo "                esac"
            echo "                shift"
            echo "            done"
            echo "            "
            echo "            # Set default values for flags"
            echo "$command" | jq -r '.flags[]? | "            local \(.name)=false"'
            echo "$command" | jq -r '.kwargs[]? | "            local \(.name)=\"\(.default // "")\""'
            echo "$command" | jq -r '.args[]? | "            local \(.name)=\"\(.default // "")\""'
            echo "            "
            echo "            # Process flags"
            echo "$command" | jq -r '.flags[]? | "            if [[ \" ${flags[@]} \" =~ \" \(.name) \" ]]; then" + "\n" + "                \(.name)=true" + "\n" + "            fi"'
            echo "            "
            echo "            # Process kwargs"
            echo "$command" | jq -r '.kwargs[]? | "            for kwarg in \"${kwargs[@]}\"; do" + "\n" + "                if [[ $kwarg == \(.name)=* ]]; then" + "\n" + "                    \(.name)=\"${kwarg#\(.name)=}\"" + "\n" + "                fi" + "\n" + "            done"'
            echo "            "
            echo "            # Process args"
            local arg_index=0
            while IFS= read -r arg_name; do
                if [ -n "$arg_name" ]; then
                    echo "            if [ \${#args[@]} -gt $arg_index ]; then"
                    echo "                $arg_name=\"\${args[$arg_index]}\""
                    echo "            fi"
                    ((arg_index++))
                fi
            done < <(echo "$command" | jq -r '.args[]?.name // empty')
            echo "            "
            echo "            # Validate required arguments"
            echo "$command" | jq -r '.kwargs[]? | select(.required == true) | "            if [ -z \"$\(.name)\" ]; then" + "\n" + "                echo \"Error: --\(.name) is required\"" + "\n" + "                '${cmd_name}'_help" + "\n" + "                exit 1" + "\n" + "            fi"'
            echo "$command" | jq -r '.args[]? | select(.required == true) | "            if [ -z \"$\(.name)\" ]; then" + "\n" + "                echo \"Error: \(.name) argument is required\"" + "\n" + "                '${cmd_name}'_help" + "\n" + "                exit 1" + "\n" + "            fi"'
            echo "            "
            echo "            # Call the command function"
            echo "            $cmd_name"
            echo "            ;;"
        fi
    done < <(jq -c '.commands[]' "$JSON_CONFIG")
    
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