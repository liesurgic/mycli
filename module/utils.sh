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

