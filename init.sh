#!/bin/bash

# lie CLI Framework - Initialize Module
# Generates a JSON configuration file for a new module

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

set -e

# Main initialization function
init() {
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
          "description": "Make them greet you!!",
          "name": "force",
          "shorthand": "f",
        }
      ]
    }
  ]
}
EOF

    print_success "Created config file: $config_file"
    print_info "Next: Edit $config_file, then run './framework/package.sh -f $config_file'"
}

# Check if we have a config file argument
if [ -n "$1" ] && [ -f "$1" ]; then
    init "$1"
else
    print_error "Config file not found or not provided"
    echo "Usage: $0 <config_file>"
    exit 1
fi 