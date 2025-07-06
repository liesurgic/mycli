#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

rm -rf ${LIE_HOME}
print_success "lie CLI uninstalled" ☠️