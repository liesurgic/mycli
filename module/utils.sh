#!/opt/homebrew/bin/bash

JSON_CONFIG=""
NAME=""
ALIAS=""
DESCRIPTION=""
VERSION=""
OUTPUT=""
LIE_HOME=""
MODULE=""

set_globals() {
    if [ -z "$JSON_CONFIG" ]; then
        JSON_CONFIG="$1"
        NAME="$(jq -r '.name // "CLI Tool"' "$JSON_CONFIG")"
        ALIAS="$(jq -r '.alias // .name // "cli"' "$JSON_CONFIG")"
        DESCRIPTION="$(jq -r '.description // "A command line interface"' "$JSON_CONFIG")"
        VERSION="$(jq -r '.version // "1.0.0"' "$JSON_CONFIG")"
        PACKAGE=".tmp/${NAME}"

#depricated
        OUTPUT="$PACKAGE/${NAME}.sh"  
#depricated

        BUILD="$PACKAGE/cli.sh"
        CMDS="$PACKAGE/${NAME}.sh"
        LIE_HOME="$HOME/.lie"
        DEPLOY="$LIE_HOME/modules/$NAME"

#depricated
        MODULE="$LIE_HOME/modules/$NAME"
#depricated
        
    fi
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_log() {
    local color="$1"
    local msg="$2"
    local icon="$3"
    local br='\n'
    echo -e "${color}${icon}  ${msg}${NC}${br}"
}

print_info() {
    print_log "$BLUE" "$1" "${2:-⦿}"
}

print_success() {
    print_log "${GREEN}" "$1" "${2:-✅}"
}

print_error() {
    print_log "${GREEN}" "$1" "${2:-❌}"
}

print_warn() {
    print_log "${YELLOW}" "$1" "${2:-⚠️}"
}