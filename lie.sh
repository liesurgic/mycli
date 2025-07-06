#!/opt/homebrew/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

init() {
    local name="$1"
    local description="$2"
    local force="$3"
    $SCRIPT_DIR/init.sh "$1"
}

package() {
    local output="$1"
    local clean="$2"
    $SCRIPT_DIR/package.sh "$1"
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
        $SCRIPT_HOME/deploy.sh "$1"
        $SCRIPT_HOME/shell.sh "$1"
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