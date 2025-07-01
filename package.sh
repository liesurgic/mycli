#!/bin/zsh

# lie CLI Framework - Package Builder
# Builds a CLI package from a JSON configuration file

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
CONFIG_FILE=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 -f <config.json> [options]"
            echo ""
            echo "Options:"
            echo "  -f, --file <file>     JSON configuration file"
            echo "  -o, --output <dir>    Output directory (default: <module_name>_cli)"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -f my_module.json"
            echo "  $0 -f my_module.json -o custom_output"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Validate required arguments
if [ -z "$CONFIG_FILE" ]; then
    print_error "Config file is required. Use -f or --file."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Extract module information
MODULE_NAME=$(grep '"name"' "$CONFIG_FILE" | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')
DESCRIPTION=$(grep '"description"' "$CONFIG_FILE" | head -1 | sed 's/.*"description": *"\([^"]*\)".*/\1/')

if [ -z "$MODULE_NAME" ]; then
    print_error "Module name not found in config file"
    exit 1
fi

# Set default output directory if not provided
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="${MODULE_NAME}_cli"
fi

print_info "Building package for: $MODULE_NAME"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate main dispatcher
cat > "$OUTPUT_DIR/$MODULE_NAME.sh" << EOF
#!/bin/zsh

# $MODULE_NAME CLI - Main Dispatcher
# Generated from $(basename $CONFIG_FILE)

set -e

# Load utilities
source "\$(dirname \$0)/utils.sh"

# Load commands
source "\$(dirname \$0)/commands.sh"

# Load config
CONFIG_FILE="\$(dirname \$0)/$(basename $CONFIG_FILE)"

# Parse command line
COMMAND="\$1"
SUBCOMMAND="\$2"
shift

# Show help if no arguments provided
if [ \$# -eq 0 ] && [ -z "\$COMMAND" ]; then
    help
    exit 0
fi

# Route commands
case "\$COMMAND" in
    help|--help|-h)
        help "\$@"
        ;;
    *)
        echo "Unknown command: \$COMMAND"
        echo "Run '$MODULE_NAME help' for available commands."
        exit 1
        ;;
esac
EOF

# Generate commands file
cat > "$OUTPUT_DIR/commands.sh" << EOF
#!/bin/zsh

# $MODULE_NAME CLI - Command Functions
# Generated from $(basename $CONFIG_FILE)

# Main help function
help() {
    echo "$MODULE_NAME - $DESCRIPTION"
    echo ""
    echo "Usage: $MODULE_NAME <command> [subcommand] [options]"
    echo ""
    echo "Commands:"
    echo "  help           Show this help message"
    echo ""
    echo "Run '$MODULE_NAME <command> help' for more info on a command."
}
EOF

# Generate utils file
cat > "$OUTPUT_DIR/utils.sh" << EOF
#!/bin/zsh

# $MODULE_NAME CLI - Utilities
# Shared utility functions for $MODULE_NAME

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
CYAN='\\033[0;36m'
NC='\\033[0m' # No Color

# Print functions
print_info() {
    echo -e "\${BLUE}ℹ️  \$1\${NC}"
}

print_success() {
    echo -e "\${GREEN}✅ \$1\${NC}"
}

print_warn() {
    echo -e "\${YELLOW}⚠️  \$1\${NC}"
}

print_error() {
    echo -e "\${RED}❌ \$1\${NC}"
}

# Config parsing utilities
get_config_value() {
    local config_file="\$1"
    local key="\$2"
    
    if [ -f "\$config_file" ]; then
        grep "\\"\$key\\"" "\$config_file" | sed 's/.*"\\"\$key\\"": *"\\"\\([^"]*\\)\\"".*/\\1/'
    fi
}

# File utilities
ensure_directory() {
    local dir="\$1"
    if [ ! -d "\$dir" ]; then
        mkdir -p "\$dir"
        print_info "Created directory: \$dir"
    fi
}

# Validation utilities
validate_name() {
    local name="\$1"
    if [[ ! "\$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*\$ ]]; then
        print_error "Invalid name: \$name. Must start with a letter and contain only letters, numbers, hyphens, and underscores."
        return 1
    fi
    return 0
}

# Module-specific utilities can be added here
EOF

# Copy config file
cp "$CONFIG_FILE" "$OUTPUT_DIR/"

# Make files executable
chmod +x "$OUTPUT_DIR/$MODULE_NAME.sh"
chmod +x "$OUTPUT_DIR/commands.sh"
chmod +x "$OUTPUT_DIR/utils.sh"

print_success "Package built in: $OUTPUT_DIR"
print_info "Files: $MODULE_NAME.sh, commands.sh, utils.sh, $(basename $CONFIG_FILE)"
print_info "Next: Run './framework/install.sh $OUTPUT_DIR' to install" 