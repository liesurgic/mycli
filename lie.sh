#!/opt/homebrew/bin/bash

set -e

LIE_HOME="$HOME/.lie"

if [ -f "$SCRIPT_HOME/lie.sh" ]; then
    CLI_HOME="${SCRIPT_HOME}"
else
    CLI_HOME="${LIE_HOME}/modules/lie.cli"
fi

UTILS_SCRIPT="$CLI_HOME/utils.sh"
BUILD_SCRIPT="$CLI_HOME/build.sh"
PACKAGE_SCRIPT="$CLI_HOME/package.sh"
DEPLOY_SCRIPT="$CLI_HOME/deploy.sh"
SHELL_SCRIPT="$CLI_HOME/shell.sh"

source "${UTILS_SCRIPT}"

init() {
    local name="$1"
    local description="$2"
    local force="$3"
    $SCRIPT_DIR/init.sh "$1"
}

package() {
    local output="$1"
    local clean="$2"
    $PACKAGE_SCRIPT "$1"
}

deploy() {
    local global="$1"
    local user="$2"
    if [ -n "$1" ] && [ -d "$1" ]; then
        package="$1"
        print_info "deploying package $package"
        name="${package%.*}"

        print_info "extracted name $name"
        config="${package}/${name}.json"
        
        print_info "extracted json config $config"
        $DEPLOY_SCRIPT "$1"
        $SHELL_SCRIPT "$1"
    else
        print_error "Package directory not found or not provided"
        echo "Usage: $0 <package_directory>"
        exit 1
    fi 
}

list() {
    local verbose="$1"
    local json="$2"
    $SCRIPT_DIR/list.sh "$1"
}