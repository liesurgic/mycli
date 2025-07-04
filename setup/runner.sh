#!/bin/bash
install() {
    # Check if module name and description are provided
    MODULE_NAME="mycli"
    DESCRIPTION="Custom Modular CLI"

    # Store the original directory
    ORIGINAL_DIR="$(pwd)"

    # Directories 
    TEMP_DIR=".tmp"
    CONFIG_DIR="./config"
    SCRIPTS_DIR="./scripts"

    # files
    CONFIG_FILENAME="$MODULE_NAME.json"
    CMD_FILENAME="$MODULE_NAME.sh"

    INIT_SCRIPT_FILENAME="init.sh"
    PACKAGE_SCRIPT_FILENAME="package.sh"
    DEPLOY_SCRIPT_FILENAME="deploy.sh"
    
    echo "Defining 0: Installation Filesystem..."
    declare -a FILES
    FILES=("$CONFIG_DIR/$CONFIG_FILENAME" "$CONFIG_DIR/$CMD_FILENAME" "$SCRIPTS_DIR/$INIT_SCRIPT_FILENAME" "$SCRIPTS_DIR/$PACKAGE_SCRIPT_FILENAME" "$SCRIPTS_DIR/$DEPLOY_SCRIPT_FILENAME")

    echo "Installing $MODULE_NAME"
    echo "The $DESCRIPTION"

    echo "Validating Filesystem..."
    for FILE in "${FILES[@]}"; do
        if [ ! -f "$FILE" ]; then
            echo "❌ Error: Required file $FILE not found."
            exit 1
        else
            echo "✅ Found: $FILE"
        fi
    done

    echo "Packaging module..."
    cp "$CONFIG_DIR/$CONFIG_FILENAME" "$TEMP_DIR/$CONFIG_FILENAME" 
    cd $TEMP_DIR
    $ORIGINAL_DIR/$SCRIPTS_DIR/$PACKAGE_SCRIPT_FILENAME -f "$CONFIG_FILENAME" -o "."

    echo "Checking if the module files were created..."
    if [ ! -f "$CMD_FILENAME" ]; then
        echo "❌ Error: Module script $CMD_FILENAME was not created"
        exit 1
    fi

    

    # 6. Copy the command script
    echo "Replacing Packaged Cmd Script"
    if [ -f "$ORIGINAL_DIR/$CONFIG_DIR/$CMD_FILENAME" ]; then
        cp "$ORIGINAL_DIR/$CONFIG_DIR/$CMD_FILENAME" "$MODULE_NAME/$CMD_FILENAME"
        echo "✅ Command script copied"
        ls "$MODULE_NAME"
    else
        echo "❌ Error: "$ORIGINAL_DIR/$CONFIG_DIR/$CMD_FILENAME" not found"
        exit 1
    fi

    # 8. Deploy the module
    echo "Deploying module..."
    $ORIGINAL_DIR/$SCRIPTS_DIR/$DEPLOY_SCRIPT_FILENAME "."

    echo "Module '$MODULE_NAME' created and deployed successfully!"
    echo "Module location: $TEMP_DIR"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install "$@"
fi