#!/bin/zsh

# lie CLI Framework - Install Package
# Installs a CLI package to the framework

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

# Parse arguments
PACKAGE_DIR=""
FORCE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE="true"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 <package_dir> [options]"
            echo ""
            echo "Options:"
            echo "  -f, --force            Force overwrite existing module"
            echo "  --help, -h             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 my_module_cli"
            echo "  $0 my_module_cli -f"
            exit 0
            ;;
        *)
            PACKAGE_DIR="$1"
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$PACKAGE_DIR" ]; then
    print_error "Package directory is required."
    echo "Usage: $0 <package_dir>"
    echo "Example: $0 my_module_cli"
    exit 1
fi

if [ ! -d "$PACKAGE_DIR" ]; then
    print_error "Package directory not found: $PACKAGE_DIR"
    exit 1
fi

# Find the main script and config file
MAIN_SCRIPT=""
CONFIG_FILE=""

for file in "$PACKAGE_DIR"/*.sh; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "commands.sh" ] && [ "$(basename "$file")" != "utils.sh" ]; then
        MAIN_SCRIPT="$file"
        break
    fi
done

for file in "$PACKAGE_DIR"/*.json; do
    if [ -f "$file" ]; then
        CONFIG_FILE="$file"
        break
    fi
done

if [ -z "$MAIN_SCRIPT" ]; then
    print_error "No main script found in $PACKAGE_DIR"
    exit 1
fi

if [ -z "$CONFIG_FILE" ]; then
    print_error "No config file found in $PACKAGE_DIR"
    exit 1
fi

# Extract module name from config
MODULE_NAME=$(grep '"name"' "$CONFIG_FILE" | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')

if [ -z "$MODULE_NAME" ]; then
    print_error "Module name not found in config file"
    exit 1
fi

print_info "Installing module: $MODULE_NAME"

# Define installation paths
LIE_HOME="$HOME/.lie"
MODULE_DIR="$LIE_HOME/modules/$MODULE_NAME"

# Check if module already exists
if [ -d "$MODULE_DIR" ] && [ "$FORCE" != "true" ]; then
    print_error "Module $MODULE_NAME already exists. Use -f to force overwrite."
    exit 1
fi

# Create module directory
if [ "$FORCE" = "true" ]; then
    rm -rf "$MODULE_DIR"
fi

mkdir -p "$MODULE_DIR"

# Copy files
cp "$MAIN_SCRIPT" "$MODULE_DIR/$MODULE_NAME.sh"
cp "$PACKAGE_DIR/commands.sh" "$MODULE_DIR/"
cp "$PACKAGE_DIR/utils.sh" "$MODULE_DIR/"
cp "$CONFIG_FILE" "$MODULE_DIR/"

# Make files executable
chmod +x "$MODULE_DIR/$MODULE_NAME.sh"
chmod +x "$MODULE_DIR/commands.sh"
chmod +x "$MODULE_DIR/utils.sh"

print_success "Module $MODULE_NAME installed successfully!"
print_info "Location: $MODULE_DIR"
print_info "Try running: lie $MODULE_NAME help" 