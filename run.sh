#!/bin/bash

# Check if module name and description are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <module_name> <description>"
    echo "Example: $0 mycli 'My awesome CLI tool'"
    exit 1
fi

MODULE_NAME=$1
DESCRIPTION=$2
TEMP_DIR=".tmp"

echo "🚀 Creating module: $MODULE_NAME"
echo "📝 Description: $DESCRIPTION"

# 1. Initialize the module
echo "📦 Step 1: Initializing module..."
./init.sh "$MODULE_NAME"

# 2. Check if the JSON config file was created
if [ ! -f "$MODULE_NAME.json" ]; then
    echo "❌ Error: Config file $MODULE_NAME.json was not created"
    exit 1
fi
echo "✅ Config file created: $MODULE_NAME.json"

# Update the description in the config file if jq is available
if command -v jq &> /dev/null; then
    jq --arg desc "$DESCRIPTION" '.description = $desc' "$MODULE_NAME.json" > "$MODULE_NAME.json.tmp"
    mv "$MODULE_NAME.json.tmp" "$MODULE_NAME.json"
    echo "✅ Updated description in config file"
fi

# 3. Package the module
echo "📦 Step 2: Packaging module..."
./package.sh -f "$MODULE_NAME.json" -o "$TEMP_DIR"

# 4. Check if the module folder was created
if [ ! -d "$TEMP_DIR/$MODULE_NAME" ]; then
    echo "❌ Error: Module folder $TEMP_DIR/$MODULE_NAME was not created"
    exit 1
fi
echo "✅ Module folder created: $TEMP_DIR/$MODULE_NAME"

# 5. Check if the module JSON exists
if [ ! -f "$TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json" ]; then
    echo "❌ Error: Module JSON $TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json does not exist"
    exit 1
fi
echo "✅ Module JSON exists: $TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json"

# 6. Copy the command script
if [ -f "cmd.sh" ]; then
    cp cmd.sh "$TEMP_DIR/$MODULE_NAME/$MODULE_NAME.sh"
    echo "✅ Command script copied: $TEMP_DIR/$MODULE_NAME/$MODULE_NAME.sh"
else
    echo "⚠️  Warning: cmd.sh not found, skipping command script copy"
fi

# 7. Update JSON with command property (assuming you have a json manipulation tool)
if command -v jq &> /dev/null; then
    # Using jq to update the JSON
    jq --arg cmd "$MODULE_NAME.sh" '.cmd = $cmd' "$TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json" > "$TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json.tmp"
    mv "$TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json.tmp" "$TEMP_DIR/$MODULE_NAME/$MODULE_NAME.json"
    echo "✅ JSON updated with command property"
else
    echo "⚠️  Warning: jq not found, skipping JSON update"
fi

# 8. Deploy the module
echo "🚀 Step 3: Deploying module..."
./deploy.sh "$TEMP_DIR"

echo "🎉 Module '$MODULE_NAME' created and deployed successfully!"
echo "📁 Module location: $TEMP_DIR/$MODULE_NAME/"