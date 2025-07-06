#!/opt/homebrew/bin/bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Command impl
init() {
    make -C "${SCRIPT_DIR}" init name="$1"
    $SCRIPT_DIR/init.sh "$1"
}

package() {
    make -C "${SCRIPT_DIR}" package name="$1"
}

deploy() {
    make -C "${SCRIPT_DIR}" deploy name="$1"
}

list() {
    make -C "${SCRIPT_DIR}" list name="$1"
}

uninstall() {
    make -C "${SCRIPT_DIR}" uninstall
}