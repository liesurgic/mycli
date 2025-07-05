# set -e enables exit immediately on non-zero exit status
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    # echo -e enables the interpretation of escape sequences in the string
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_written() {
    echo -e "${BLUE}📝 $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

raise_error() {
    local error_message="${1:-Error raised without message}"
    print_error "${error_message}"
    exit 1
}

ensure_jq_installed() {
    # Check if jq is installed
    if ! command -v jq &>/dev/null; then
        raise_error "jq must be install to use this package"
    fi
}


# Config parsing utilities
get_config_value() {
    local config_file="$1"
    local key="$2"
    
    if [ -f "$config_file" ]; then
        grep "\"$key\"" "$config_file" | sed 's/.*"\"$key\"": *"\"\([^"]*\)\"".*/\1/'
    fi
}

# JSON value helpers
read_json_value() {
    local config_file="$1"
    local key="$2"
    jq -r ".$key // empty" "$config_file" 2>/dev/null
}

read_json_values() {
    local config_file="$1"
    local key="$2"
    if [[ "$key" == *.* ]]; then
        jq -r '
          def splitdot: split(".");
          getpath(splitdot("'"$key"'"))[]? | @base64
        ' "$config_file" 2>/dev/null
    else
        jq -r ".$key[]? | @base64" "$config_file" 2>/dev/null
    fi
}

# File utilities
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_info "Created directory: $dir"
    fi
}

# Validation utilities
validate_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        print_error "Invalid name: $name. Must start with a letter and contain only letters, numbers, hyphens, and underscores."
        return 1
    fi
    return 0
}


# Read all commands (returns base64-encoded JSON for each command)
read_commands() {
    local config_file="$1"
    read_json_values "$config_file" "commands"
}

# Read flags for a given command (by index)
read_command_flags() {
    local config_file="$1"
    local command_index="$2"
    jq -r ".commands[$command_index].flags[] | @base64" "$config_file" 2>/dev/null
}

# Read the module/CLI name
read_module_name() {
    local config_file="$1"
    local default="${2:-"MyCLI"}"
    local value=$(read_json_value "$config_file" "name")
    echo "${value:-$default}"
}

# Read the module/CLI name
read_module_alias() {
    local config_file="$1"
    local default=$(read_module_name "$config_file")
    local value=$(read_json_value "$config_file" "alias")
    echo "${value:-$default}"
}

# Read the module/CLI description
read_module_description() {
    local config_file="$1"
    local default="${2:-"My Custom CLI"}"
    local value=$(read_json_value "$config_file" "description")
    echo "${value:-$default}"
}

# Extract command name from base64-encoded command JSON
read_command_name() {
    local command_b64="$1"
    local command_json=$(echo "$command_b64" | base64 -d)
    echo "$command_json" | jq -r '.name // empty'
}

# Extract command description from base64-encoded command JSON
read_command_description() {
    local command_b64="$1"
    local command_json=$(echo "$command_b64" | base64 -d)
    echo "$command_json" | jq -r '.description // empty'
}

# Extract command info as pipe-separated string (name|description)
read_command_info() {
    local command_b64="$1"
    local command_json=$(echo "$command_b64" | base64 -d)
    local cmd_name=$(echo "$command_json" | jq -r '.name // empty')
    local cmd_desc=$(echo "$command_json" | jq -r '.description // empty')
    echo "$cmd_name|$cmd_desc"
}

# Extract flag info from base64-encoded flag JSON
extract_flag_info() {
    local flag_b64="$1"
    local flag_json=$(echo "$flag_b64" | base64 -d)
    
    local flag_name=$(echo "$flag_json" | jq -r '.name // empty')
    local flag_shorthand=$(echo "$flag_json" | jq -r '.shorthand // empty')
    local flag_desc=$(echo "$flag_json" | jq -r '.description // empty')
    
    echo "$flag_name|$flag_shorthand|$flag_desc"
}

# Get flag names for a specific command by name
read_command_flag_names() {
    local config_file="$1"
    local command_name="$2"
    
    # Use jq to find the command by name and extract flag names
    jq -r --arg cmd_name "$command_name" '
        .commands[] | 
        select(.name == $cmd_name) | 
        .flags[]?.name // empty
    ' "$config_file" 2>/dev/null
}

# Get all command names from config
read_command_names() {
    local config_file="$1"
    
    # Use jq to extract all command names
    jq -r '.commands[]?.name // empty' "$config_file" 2>/dev/null
}

# You can add more helpers as needed, e.g. for version, author, etc. 