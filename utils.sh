#!/opt/homebrew/bin/bash

LIE_HOME="$HOME/.lie"

JSON_CONFIG=""
NAME=""
ALIAS=""
DESCRIPTION=""
VERSION=""
OUTPUT=""
MODULE=""

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
    echo -e "${br}${color}${icon}  ${msg}${NC}"
}

print_info() {
    print_log "$BLUE" "$1" "${2:-⦿}"
}

print_completed() {
    local icon="⦿"
    local msg="$1"
    echo -e "${GREEN}${icon}  ${msg}${NC}"
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

validate_config() {
    local config_file="$1"
    
    # Check if file exists
    if [ ! -f "$config_file" ]; then
        print_error "Config file not found: $config_file"
        return 1
    fi
    
    # Check if it's valid JSON
    if ! jq empty "$config_file" 2>/dev/null; then
        print_error "Invalid JSON in config file: $config_file"
        return 1
    fi
    
    # Check required properties exist and are not null/empty
    local name=$(jq -r '.name' "$config_file")
    local description=$(jq -r '.description' "$config_file")
    local version=$(jq -r '.version' "$config_file")
    
    # Validate name exists and is not null/empty
    if [ "$name" = "null" ] || [ -z "$name" ]; then
        print_error "Config file is missing required 'name' property"
        return 1
    fi
    
    # Validate name contains only lowercase letters
    if [[ ! "$name" =~ ^[a-z]+$ ]]; then
        print_error "Name must contain only lowercase letters (a-z), got: $name"
        return 1
    fi
    
    # Validate description exists and is not null/empty
    if [ "$description" = "null" ] || [ -z "$description" ]; then
        print_error "Config file is missing required 'description' property"
        return 1
    fi
    
    # Validate version exists and is not null/empty
    if [ "$version" = "null" ] || [ -z "$version" ]; then
        print_error "Config file is missing required 'version' property"
        return 1
    fi
    
    print_success "Config validation passed"
    return 0
}

set_globals() {
    if [ -z "$JSON_CONFIG" ]; then
        # Validate config first
        if ! validate_config "$1"; then
            return 1
        fi
        
        JSON_CONFIG="$1"
        NAME="$(jq -r '.name' "$JSON_CONFIG")"
        DESCRIPTION="$(jq -r '.description' "$JSON_CONFIG")"
        VERSION="$(jq -r '.version' "$JSON_CONFIG")"
        
        # PACKAGE="${NAME}.cli"

        # MODULE_SCRIPT="$PACKAGE/${NAME}.sh"

        MODULE_NAME="${NAME}.cli"
        MODULE_HOME="$LIE_HOME/modules/${MODULE_NAME}"
    fi   
}