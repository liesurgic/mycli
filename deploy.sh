#!/bin/bash

# CLI Deploy - Installs CLI module from package
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

deploy() {
    set_globals "$1"
    local force="$2"

    print_info "Deploying $NAME"

    # Check if module already exists
    if [ -d "$MODULE_HOME" ] && [ "$force" != "true" ]; then
        rm -rf "$MODULE_HOME"
        # print_error "Module $NAME already exists. Use -f to force overwrite."
        # exit 1
    fi

    # Create module directory
    if [ "$force" = "true" ]; then
        print_info "Force overwriting existing module"
        rm -rf "$MODULE_HOME"
    fi
    
    mkdir -p "$MODULE_HOME"

    print_info "Copying package into module"
    cp -r "./$MODULE_NAME"/* "$MODULE_HOME/"

    print_info "Making scripts executable"
    chmod +x "$MODULE_HOME"/*.sh

    print_success "Deployed ${NAME} to ${MODULE_HOME}"
}

# Check if we have a config file argument
if [ -n "$1" ] && [ -f "$1" ]; then
    deploy "$1"
else
    print_error "Config file not found or not provided"
    echo "Usage: $0 <config_file>"
    exit 1
fi 