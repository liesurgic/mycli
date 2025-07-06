#!/opt/homebrew/bin/bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Command impl
init() {
    $SCRIPT_DIR/init.sh "$1"
}

package() {
    $SCRIPT_DIR/package.sh "$1"
}

deploy() {
    $SCRIPT_DIR/deploy.sh "$1"
}

list() {
    $SCRIPT_DIR/list.sh "$1"
}

uninstall() {
    $SCRIPT_DIR/uninstall.sh "$1"
}