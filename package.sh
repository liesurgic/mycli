#!/opt/homebrew/bin/bash

# CLI Package Builder - Builds package from JSON config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

package() {
    set_globals "$1"

    print_info "Starting to create package directory: $MODULE_NAME"
    mkdir -p "./$MODULE_NAME"
    print_completed "Package directory $MODULE_NAME created successfully"
    
    print_info "Starting to copy config file to ./${MODULE_NAME}/${NAME}.json"
    cp "$JSON_CONFIG" "./${MODULE_NAME}/${NAME}.json"
    print_completed "Config file added to ./${MODULE_NAME}/${NAME}.json"
    
    print_info "Starting to copy utils to package"
    cp "$SCRIPT_DIR/utils.sh" "./$MODULE_NAME/utils.sh"
    print_completed "Utils added to package"
    
    print_info "Starting to build the CLI"
    "$SCRIPT_DIR/build.sh" "./$MODULE_NAME/$NAME.json"
    print_completed "CLI build process completed"
    
    print_completed "Packaged ${NAME} ${MODULE_NAME}" "📦"
}


if [ -n "$1" ] && [ -f "$1" ]; then
    package "$1"
    exit 0
else
    print_error "Config file not found or not provided"
    echo "Usage: $0 <config_file>"
    exit 1
fi 
