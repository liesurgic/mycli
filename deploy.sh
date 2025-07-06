#!/bin/bash

# CLI Deploy - Installs CLI module from package
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

deploy() {
    local force="$2"

    print_info "Deploying $NAME in $MODULE_NAME to $MODULE_HOME"

    if [ -z "$MODULE_HOME" ]; then 
        print_error "Module home is not set" 
        return 1
    fi

    # Check if module already exists
    if [ -d "$MODULE_HOME" ] && [ "$force" != "true" ]; then
        rm -rf "$MODULE_HOME"
        # print_error "Module $NAME already exists. Use -f to force overwrite."
        # exit 1
    fi

    # Create module directory
    if [ "$force" = "true" ]; then
        print_info "Force overwriting existing module ${MODULE_HOME}"
        rm -rf "$MODULE_HOME"
    fi
    
    mkdir -p "$MODULE_HOME"

    print_info "Copying package into module"
    cp -r "./$MODULE_NAME"/* "$MODULE_HOME/"

    print_info "Making scripts executable"
    chmod +x "$MODULE_HOME"/*.sh

    print_success "Deployed ${MODULE_NAME} to ${MODULE_HOME}"
}


if entry_point "$1"; then
    deploy
    exit 0
else
    exit 1
fi