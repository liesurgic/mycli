#!/bin/bash

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

# Parse config file and extract module info
parse_config() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        print_error "Config file not found: $config_file"
        return 1
    fi

    # Extract module information
    local module_name=$(grep '"name"' "$config_file" | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')
    local description=$(grep '"description"' "$config_file" | head -1 | sed 's/.*"description": *"\([^"]*\)".*/\1/')

    if [ -z "$module_name" ]; then
        print_error "Module name not found in config file"
        return 1
    fi

    echo "$module_name|$description"
}

copy() {
    local config_file="$1"
    local output_dir="$2"

    print_info "Copying config file"
    cp "$config_file" "$output_dir/"
    print_success "Copied: $(basename $config_file)"
}

# Main packaging function
package() {
    local module_name="$1"
    local output_dir="$2"

    # Validate inputs
    if [ -z "$config_file" ]; then
        print_error "Config file is required"
        echo "Usage: package_module <config_file> [output_dir]"
        return 1
    fi

    if [ ! -f "$config_file" ]; then
        print_error "Config file not found: $config_file"
        return 1
    fi

    # Parse config
    local config_info=$(parse_config "$config_file")
    if [ $? -ne 0 ]; then
        return 1
    fi

    local module_name=$(echo "$config_info" | cut -d'|' -f1)
    local description=$(echo "$config_info" | cut -d'|' -f2)

    # Set default output directory if not provided
    if [ -z "$output_dir" ]; then
        output_dir="${module_name}_cli"
    fi

    print_info "Building package for: $module_name"
    print_info "Output directory: $output_dir"

    # Create output directory
    mkdir -p "$output_dir"

    # Generate all files
    generate_main_script "$module_name" "$config_file" "$output_dir"
    generate_commands "$module_name" "$description" "$output_dir"
    copy "$utils_file" "$output_dir"
    copy "$config_file" "$output_dir"

    print_success "Package built successfully in: $output_dir"
    print_info "Files: $module_name.sh, commands.sh, utils.sh, $(basename $config_file)"
}

# Test function to validate a config file
test_config() {
    local config_file="$1"

    if [ -z "$config_file" ]; then
        print_error "Config file is required"
        echo "Usage: test_config <config_file>"
        return 1
    fi

    print_info "Testing config file: $config_file"

    local config_info=$(parse_config "$config_file")
    if [ $? -eq 0 ]; then
        local module_name=$(echo "$config_info" | cut -d'|' -f1)
        local description=$(echo "$config_info" | cut -d'|' -f2)

        print_success "Config is valid!"
        print_info "Module name: $module_name"
        print_info "Description: $description"
    else
        print_error "Config validation failed"
        return 1
    fi
}

# Clean function to remove generated files
clean_package() {
    local output_dir="$1"

    if [ -z "$output_dir" ]; then
        print_error "Output directory is required"
        echo "Usage: clean_package <output_dir>"
        return 1
    fi

    if [ -d "$output_dir" ]; then
        print_info "Removing package directory: $output_dir"
        rm -rf "$output_dir"
        print_success "Cleaned: $output_dir"
    else
        print_warn "Directory does not exist: $output_dir"
    fi
}

# Help function
show_help() {
    echo "Usage: $0 <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  build <config> [output]    Build a CLI package"
    echo "  test <config>              Test/validate a config file"
    echo "  clean <dir>                Remove generated package directory"
    echo "  help                       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build my_module.json"
    echo "  $0 build my_module.json custom_output"
    echo "  $0 test my_module.json"
    echo "  $0 clean my_module_cli"
    echo ""
    echo "Functions available when sourced:"
    echo "  package_module <config> [output]  Build a CLI package"
    echo "  test_config <config>              Test a config file"
    echo "  clean_package <dir>               Clean package directory"
    echo "  parse_config <config>             Parse and validate config"
    echo "  generate_main_script <name> <config> <output>  Generate main script"
    echo "  generate_commands <name> <desc> <output>      Generate commands"
    echo "  copy_utils <name> <output>                Generate utilities"
    echo "  copy_config <config> <output>                 Copy config file"
}

# Main execution logic
main() {
    local command="$1"

    case "$command" in
    build)
        shift # Remove 'build' from arguments
        package_module "$@"
        ;;
    test)
        shift # Remove 'test' from arguments
        test_config "$@"
        ;;
    clean)
        shift # Remove 'clean' from arguments
        clean_package "$@"
        ;;
    help | --help | -h)
        show_help
        ;;
    *)
        if [ -z "$command" ]; then
            print_error "Command is required."
            show_help
            exit 1
        else
            print_error "Unknown command: $command"
            show_help
            exit 1
        fi
        ;;
    esac
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    main "$@"
else
    # Script is being sourced
    echo "Functions loaded: package_module, test_config, clean_package, parse_config"
    echo "Usage: package_module <config_file> [output_dir]"
fi
