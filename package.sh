#!/opt/homebrew/bin/bash

# CLI Package Builder - Builds package from JSON config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

package() {
    print_info "Starting to create package directory: ${MODULE_NAME}"
    mkdir -p "./${MODULE_NAME}"
    print_completed "Package directory ${MODULE_NAME} created successfully"
    
    print_info "Starting to copy config file to ./${MODULE_NAME}/${NAME}.json"
    cp "${JSON_CONFIG}" "./${MODULE_NAME}/${NAME}.json"
    print_completed "Config file added to ./${MODULE_NAME}/${NAME}.json"
    
    print_info "Starting to copy utils to package"
    cp "$UTILS_SCRIPT" "./${MODULE_NAME}/utils.sh"
    print_completed "Utils added to package"
    
    print_info "Starting to build the CLI"
    "${CLI_HOME}/build.sh" "./${MODULE_NAME}/${NAME}.json"
    print_completed "CLI build process completed"
    
    print_completed "Packaged ${MODULE_NAME}" "📦"
}

if entry_point "$1"; then
    package
    exit 0
else
    exit 1
fi