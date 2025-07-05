#!/opt/homebrew/bin/bash

# CLI Package Builder - Builds package from JSON config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

package() {
    set_globals $1

    print_info "Packaging module: $NAME"
    
    local module_dir=".tmp/$NAME"
    
    mkdir -p "$module_dir"
    print_info "Created Module Dir: $module_dir"
    
    # Copy config file
    cp "$JSON_CONFIG" "$module_dir/$NAME.json"
    print_info "Copied: Config $NAME.json"
    
    # Copy utils
    cp "$SCRIPT_DIR/utils.sh" "$module_dir/utils.sh"
    print_info "Copied: Utils utils.sh"
    
    # Build the CLI
    "$SCRIPT_DIR/build.sh" "$module_dir/$NAME.json"
    
    print_success "Packaged ${NAME} ${PACKAGE}" "📦"
}

validate() {
    set_globals $1

    if [ -z "$JSON_CONFIG" ]; then
        print_error "Config file is required"
        return 1
    fi

    if [ ! -f "$JSON_CONFIG" ]; then
        print_error "Config file not found: $JSON_CONFIG"
        return 1
    fi

    if [ ! -f "$NAME" ]; then
        print_error "Config file is missing name: $NAME"
        return 1
    fi

    if [ ! -f "$DESCRIPTION" ]; then
        print_error "Config file is missing name: $DESCRIPTION"
        return 1
    fi

    if [ ! -f "$VERSION" ]; then
        print_error "Config file is missing version: $VERSION"
        return 1
    fi


    print_info "Testing config file: $JSON_CONFIG"

    # Test JSON validity
    if jq empty "$JSON_CONFIG" 2>/dev/null; then
        print_success "✅ Config is valid!"
        print_info "Module name: $NAME"
        print_info "Description: $DESCRIPTION"
        print_info "Version: $VERSION"
    else
        print_error "Config validation failed - invalid JSON"
        return 1
    fi
}

# Clean function to remove generated files
clean_package() {
    local module_name="$1"

    if [ -z "$module_name" ]; then
        print_error "Module name is required"
        echo "Usage: clean_package <module_name>"
        return 1
    fi

    local module_dir=".tmp/$module_name"
    if [ -d "$module_dir" ]; then
        print_info "Removing package directory: $module_dir"
        rm -rf "$module_dir"
        print_success "🧹 Cleaned: $module_dir"
    else
        print_warn "Directory does not exist: $module_dir"
    fi
}

if [ -n "$1" ] && [ -f "$1" ]; then
    validate "$1"
    package "$1"
else
    print_error "Config file not found or not provided"
    echo "Usage: $0 <config_file>"
    exit 1
fi 

