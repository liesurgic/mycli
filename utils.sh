#!/opt/homebrew/bin/bash

LIE_HOME="$HOME/.lie"
MODULES_DIRECTORY="${LIE_HOME}/modules"


JSON_CONFIG=""
NAME=""
DESCRIPTION=""
VERSION=""
MODULE_NAME=""
ENTRY_POINT_SCRIPT_NAME=""
MODULE_HOME=""
MODULE_ENTRY_POINT=""
MODULE_COMMAND_SCRIPT=""


if [ -f "$SCRIPT_HOME/lie.sh" ]; then
    CLI_HOME="${SCRIPT_HOME}"
else
    CLI_HOME="${LIE_HOME}/modules/lie.cli"
fi


UTILS_SCRIPT="${CLI_HOME}/utils.sh"

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
    print_log "$BLUE" "$1" "${2:-⦿}" >&2
}

print_completed() {
    local icon="⦿"
    local msg="$1"
    echo -e "${GREEN}${icon}  ${msg}${NC}"
}

print_success() {
    print_log "${GREEN}" "$1" "${2:-✅}" >&2
}

print_error() {
    print_log "${GREEN}" "$1" "${2:-❌}" >&2
}

print_warn() {
    print_log "${YELLOW}" "$1" "${2:-⚠️}" >&2
}

# Smart argument parser
parse_config_arg() {
    local arg="$1"
    local config_file=""
    
    if [ -z "$arg" ]; then
        print_error "No argument provided"
        return 1
    fi
    
    # Case 1: Ends with .json - use as-is
    if [[ "$arg" == *.json ]]; then
        if [ -f "$arg" ]; then
            config_file="$arg"
            print_info "Using JSON config file: $config_file"
        else
            print_error "JSON file not found: $arg"
            return 1
        fi
    
    # Case 2: Ends with .cli - check if directory and find .json
    elif [[ "$arg" == *.cli ]]; then
        if [ -d "$arg" ]; then
            local name="${arg%.cli}"  # Remove .cli suffix
            local json_file="$arg/${name##*/}.json"  # Get just the name part
            
            if [ -f "$json_file" ]; then
                config_file="$json_file"
                print_info "Found config in .cli directory: $config_file"
            else
                print_error "No .json file found in $arg directory"
                return 1
            fi
        else
            print_error ".cli directory not found: $arg"
            return 1
        fi
    
    # Case 3: Plain string - look for name.json in current directory
    else
        local json_file="./$arg.json"
        if [ -f "$json_file" ]; then
            config_file="$json_file"
            print_info "Using config file from current directory: $config_file"
        else
            print_error "No config file found: $json_file"
            return 1
        fi
    fi
    
    echo "$config_file"
    return 0
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
        # Parse the argument to get the config file
        local config_file=$(parse_config_arg "$1")
        if [ $? -ne 0 ]; then
            return 1
        fi
        
        # Validate config first
        if ! validate_config "$config_file"; then
            return 1
        fi
        
        JSON_CONFIG="$config_file"
        NAME="$(jq -r '.name' "$JSON_CONFIG")"
        DESCRIPTION="$(jq -r '.description' "$JSON_CONFIG")"
        VERSION="$(jq -r '.version' "$JSON_CONFIG")"

        MODULE_NAME="${NAME}.cli"
        ENTRY_POINT_SCRIPT_NAME="cli.sh"
        MODULE_COMMAND_SCRIPT_NAME="${NAME}.sh"
        MODULE_HOME="${MODULES_DIRECTORY}/${MODULE_NAME}"
        MODULE_ENTRY_POINT="${MODULE_HOME}/${ENTRY_POINT_SCRIPT_NAME}"
        MODULE_COMMAND_SCRIPT="${MODULE_HOME}/${MODULE_COMMAND_SCRIPT_NAME}"
    fi   
}

entry_point() {
    if [ -n "$1" ]; then
        if set_globals "$1"; then
            return 0
        else
            print_error "Invalid argument: $1"
            echo "Usage: $0 <config_file|config_dir|name>"
            echo "Examples:"
            echo "  $0 lie.json          # Direct JSON file"
            echo "  $0 lie.cli           # Directory containing config"
            echo "  $0 lie               # Look for lie.json in current dir"
            return 1
        fi
    else
        print_error "No argument provided"
        echo "Usage: $0 <config_file|config_dir|name>"
        return 1
    fi 
}
