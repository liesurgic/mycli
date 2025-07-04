#!/bin/bash

# lie CLI Framework - Initialize Module
# Generates a JSON configuration file for a new module

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Main initialization function
init_module() {
    local module_name="$1"
    
    # Check if module name is provided
    if [ -z "$module_name" ]; then
        print_error "Module name is required."
        echo "Usage: init_module <module_name>"
        echo "Example: init_module my_module"
        return 1
    fi

    # Validate module name
    if [[ ! "$module_name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        print_error "Invalid module name: $module_name. Must start with a letter and contain only letters, numbers, hyphens, and underscores."
        return 1
    fi

    print_info "Initializing module: $module_name"

    # Create config file
    local config_file="$module_name.json"

    if [ -f "$config_file" ]; then
        print_error "Config file $config_file already exists."
        return 1
    fi

    # Generate basic config
    cat > "$config_file" << EOF
{
  "name": "$module_name",
  "description": "A CLI module for $module_name",
  "version": "1.0.0",
  "commands": [
    {
      "name": "hello",
      "description": "Say hello",
      "flags": [
        {
          "name": "name",
          "description": "Name to greet",
          "required": false,
          "default": "World"
        }
      ]
    }
  ]
}
EOF

    print_success "Created config file: $config_file"
    print_info "Next: Edit $config_file, then run './framework/package.sh -f $config_file'"
}

# Help function
show_help() {
    echo "Usage: $0 <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  init <module_name>    Initialize a new module"
    echo "  help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 init my_module"
    echo "  $0 help"
    echo ""
    echo "Functions available when sourced:"
    echo "  init_module <name>    Initialize a module"
    echo "  print_info <message>  Print info message"
    echo "  print_success <msg>   Print success message"
    echo "  print_error <msg>     Print error message"
}

# Main execution logic
main() {
    local command="$1"
    
    case "$command" in
        init)
            shift  # Remove 'init' from arguments
            init_module "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            if [ -z "$command" ]; then
                print_error "Command is required."
                show_help
                exit 1
            else
                print_error "Unknown command: $command"
                show_help
                exit 1
            fi
            ;;
    esac
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    main "$@"
else
    # Script is being sourced
    echo "Functions loaded: init_module, print_info, print_success, print_error"
    echo "Usage: init_module <module_name>"
fi 