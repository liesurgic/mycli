#!/bin/bash

# CLI Deploy - Installs CLI module from package
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

validate() {
    set_globals "$1"

    if [ -z "$PACKAGE" ] || [ ! -d "$PACKAGE" ]; then
        print_error "Package not found: $PACKAGE"
        exit 1
    fi
}

add_to_shell() {
    local name="$1"
    local deploy_path="$2"
    local shell_rc="$HOME/.zshrc"
    local alias_line="alias $name='$deploy_path/$name.sh'"
    
    # Check if alias already exists
    if grep -q "alias $name=" "$shell_rc" 2>/dev/null; then
        print_info "Alias for $name already exists in $shell_rc"
        return 0
    fi
    
    # Add alias to .zshrc
    echo "" >> "$shell_rc"
    echo "# CLI Module: $name" >> "$shell_rc"
    echo "$alias_line" >> "$shell_rc"
    
    print_success "Added $name alias to $shell_rc"
    print_info "Run 'source ~/.zshrc' or restart your terminal to use $name"
}

deploy() {
    set_globals "$1"
    local force="$2"

    print_info "Deploying $NAME"

    # Check if module already exists
    if [ -d "$DEPLOY" ] && [ "$force" != "true" ]; then
        rm -rf "$DEPLOY"
        # print_error "Module $NAME already exists. Use -f to force overwrite."
        # exit 1
    fi

    # Create module directory
    if [ "$force" = "true" ]; then
        print_info "Force overwriting existing module"
        rm -rf "$DEPLOY"
    fi
    
    mkdir -p "$DEPLOY"

    print_info "Copying package into module"
    cp -r "$PACKAGE"/* "$DEPLOY/"

    print_info "Making files executable"
    chmod +x "$DEPLOY/$NAME.sh"
    chmod +x "$DEPLOY/utils.sh"


    rm -r .tmp
    # Add to shell configuration
    add_to_shell "$NAME" "$DEPLOY"

    print_success "Deployed ${NAME} ${DEPLOY}"
}

if [ -n "$1" ] && [ -f "$1" ]; then
    validate "$1"
    deploy "$1"
else
    print_error "Config file not found or not provided"
    echo "Usage: $0 <config_file>"
    exit 1
fi 