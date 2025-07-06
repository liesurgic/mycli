#!/opt/homebrew/bin/bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Command impl
init() {
    # Use the parsed variables
    if [ "$force" = "true" ]; then
        echo "Force flag is set - would overwrite existing files"
    fi
    
    if [ -n "$name" ]; then
        echo "Project name: $name"
    fi
    
    if [ -n "$description" ]; then
        echo "Project description: $description"
    fi
    
    if [ -n "$template" ]; then
        echo "Template: $template"
    fi
    
    # Use the parsed config argument or default to current directory
    local config_arg="${config:-.}"
    make -C "${SCRIPT_DIR}" init name="$config_arg"
    $SCRIPT_DIR/init.sh "$config_arg"
}

package() {
    # Use the parsed config argument or default to current directory
    local config_arg="${config:-.}"
    
    # Use parsed flags and kwargs
    if [ "$clean" = "true" ]; then
        echo "Clean flag is set - would clean build directory"
    fi
    
    if [ -n "$output" ] && [ "$output" != "./" ]; then
        echo "Output directory: $output"
    fi
    
    make -C "${SCRIPT_DIR}" package name="$config_arg"
}

deploy() {
    # Use the parsed package argument or default to current directory
    local package_arg="${package:-.}"
    make -C "${SCRIPT_DIR}" deploy name="$package_arg"
}

list() {
    # Use parsed flags
    if [ "$verbose" = "true" ]; then
        echo "Verbose flag is set - showing detailed information"
    fi
    
    if [ "$json" = "true" ]; then
        echo "JSON flag is set - outputting in JSON format"
    fi
    
    # List command doesn't need arguments
    make -C "${SCRIPT_DIR}" list
}

uninstall() {
    make -C "${SCRIPT_DIR}" uninstall
}