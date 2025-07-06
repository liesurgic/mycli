#!/bin/bash

# CLI Deploy - Installs CLI module from package
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"


shell() {
    set_globals "$1"
    local shell_rc="$HOME/.zshrc"
    local alias="alias ${NAME}='${MODULE_HOME}/cli.sh'"
    
    # Check if .zshrc exists
    if [ ! -f "$shell_rc" ]; then
        print_info ".zshrc not found at $shell_rc - no alias created"
        print_warn "Ensure to add to your choice of terminal"
        return 0
    fi
    
    # Check if alias already exists
    if grep -q "alias ${NAME}=" "$shell_rc" 2>/dev/null; then
        print_info "Alias for ${NAME} already exists in $shell_rc"
        return 0
    fi
    
    # Add alias to .zshrc
    echo "" >> "$shell_rc"
    echo "# CLI Module: ${NAME}" >> "$shell_rc"
    echo "$alias" >> "$shell_rc"
    
    print_success "Added ${NAME} alias to $shell_rc"
    print_info "Run 'source ~/.zshrc' or restart your terminal to use ${NAME} CLI"
}

# Check if we have a config file argument
if [ -n "$1" ] && [ -f "$1" ]; then
    shell "$1"
else
    print_error "Config file not found or not provided"
    echo "Usage: $0 <config_file>"
    exit 1
fi 