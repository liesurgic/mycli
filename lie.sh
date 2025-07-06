#!/opt/homebrew/bin/bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Command impl
init() {
    make -c "${SCRIPT_DIR}" init "$1"
    $SCRIPT_DIR/init.sh "$1"
}

package() {
    make -c "${SCRIPT_DIR}" package "$1"
    make -c "${SCRIPT_DIR}" build "$1"
}

deploy() {
    make -c "${SCRIPT_DIR}" deploy "$1"
}

list() {
    make -c "${SCRIPT_DIR}" list "$1"
}

uninstall() {
    make -c "${SCRIPT_DIR}" uninstall "$1"
}