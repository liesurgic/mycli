#!/bin/zsh

# lie CLI Framework - Initialize Module
# Generates a JSON configuration file for a new module

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if module name is provided
if [ $# -eq 0 ]; then
    print_error "Module name is required."
    echo "Usage: $0 <module_name>"
    echo "Example: $0 my_module"
    exit 1
fi

MODULE_NAME="$1"

# Validate module name
if [[ ! "$MODULE_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
    print_error "Invalid module name: $MODULE_NAME. Must start with a letter and contain only letters, numbers, hyphens, and underscores."
    exit 1
fi

print_info "Initializing module: $MODULE_NAME"

# Create config file
CONFIG_FILE="$MODULE_NAME.json"

if [ -f "$CONFIG_FILE" ]; then
    print_error "Config file $CONFIG_FILE already exists."
    exit 1
fi

# Generate basic config
cat > "$CONFIG_FILE" << EOF
{
  "name": "$MODULE_NAME",
  "description": "A CLI module for $MODULE_NAME",
  "version": "1.0.0",
  "commands": [
    {
      "name": "hello",
      "description": "Say hello",
      "flags": [
        {
          "name": "name",
          "description": "Name to greet",
          "required": false,
          "default": "World"
        }
      ]
    }
  ]
}
EOF

print_success "Created config file: $CONFIG_FILE"
print_info "Next: Edit $CONFIG_FILE, then run './framework/package.sh -f $CONFIG_FILE'" 