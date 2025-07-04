#!/bin/zsh

# mycli CLI package Installer
# Installs the package to $HOME/.mycli and makes mycli command available

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
MYCLI_HOME="$HOME/.mycli"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}🚀 Installing mycli CLI package...${NC}"
echo -e "${BLUE}📁 Script directory: $SCRIPT_DIR${NC}"
echo -e "${BLUE}📁 Project root: $PROJECT_ROOT${NC}"

# Step 1: Validate required files exist
echo -e "${YELLOW}📋 Step 1: Validating required files...${NC}"

# Define required files
declare -a REQUIRED_FILES=(
    "$PROJECT_ROOT/config/mycli.json"
    "$PROJECT_ROOT/config/mycli.sh"
    "$PROJECT_ROOT/scripts/init.sh"
    "$PROJECT_ROOT/scripts/package.sh"
    "$PROJECT_ROOT/scripts/deploy.sh"
)

# Check each required file
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Error: Required file $file not found${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Found: $(basename "$file")${NC}"
    fi
done

# Step 2: Initialize the module (if needed)
echo -e "${YELLOW}📦 Step 2: Initializing module...${NC}"
cd "$PROJECT_ROOT"
if [ ! -f "mycli.json" ]; then
    echo -e "${BLUE}Creating module configuration...${NC}"
    ./scripts/init.sh "mycli"
else
    echo -e "${GREEN}✅ Module configuration already exists${NC}"
fi

# Step 3: Package the module
echo -e "${YELLOW}📦 Step 3: Packaging module...${NC}"
./scripts/package.sh -f "mycli.json" -o ".tmp"

# Step 4: Deploy the module
echo -e "${YELLOW}🚀 Step 4: Deploying module...${NC}"
./scripts/deploy.sh ".tmp"

# Step 5: Install mycli command globally
echo -e "${YELLOW}🔧 Step 5: Installing mycli command...${NC}"

# Create mycli home directory
mkdir -p "$MYCLI_HOME"
mkdir -p "$MYCLI_HOME/modules"
mkdir -p "$MYCLI_HOME/utils"
mkdir -p "$MYCLI_HOME/templates"
mkdir -p "$MYCLI_HOME/config"

# Copy the packaged module to mycli home
if [ -d ".tmp" ]; then
    cp -r .tmp/* "$MYCLI_HOME/"
    echo -e "${GREEN}✅ Module files copied to $MYCLI_HOME${NC}"
fi

# Create bin directory if not exists
mkdir -p "$BIN_DIR"

# Create the mycli wrapper script
cat > "$BIN_DIR/mycli" << 'EOF'
#!/bin/zsh
"$HOME/.mycli/mycli.sh" "$@"
EOF

chmod +x "$BIN_DIR/mycli"

# Add to PATH using a block marker approach
ZSHRC="$HOME/.zshrc"
MYCLI_BLOCK_START="# >>> mycli PATH setup >>>"
MYCLI_BLOCK_END="# <<< mycli PATH setup <<<"
MYCLI_PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

# Remove any existing block
if [ -f "$ZSHRC" ]; then
    sed -i.bak "/$MYCLI_BLOCK_START/,/$MYCLI_BLOCK_END/d" "$ZSHRC" 2>/dev/null || true
fi

# Add a newline if the file doesn't end with one
if [ -f "$ZSHRC" ]; then
    tail -c1 "$ZSHRC" | read -r _ || echo >> "$ZSHRC"
fi

# Append the new block
{
  echo "$MYCLI_BLOCK_START"
  echo "$MYCLI_PATH_LINE"
  echo "$MYCLI_BLOCK_END"
} >> "$ZSHRC"

echo -e "${GREEN}✅ Added $BIN_DIR to PATH in ~/.zshrc${NC}"

# Create initial config if it doesn't exist
if [ ! -f "$MYCLI_HOME/config/config.json" ]; then
    cat > "$MYCLI_HOME/config/config.json" << 'EOF'
{
  "package": {
    "version": "1.0.0",
    "modules_dir": "modules",
    "utils_dir": "utils",
    "templates_dir": "templates"
  },
  "settings": {
    "log_level": "info",
    "timeout": 30
  }
}
EOF
    echo -e "${GREEN}✅ Created initial configuration${NC}"
fi

# Clean up temporary files
if [ -d ".tmp" ]; then
    rm -rf .tmp
    echo -e "${BLUE}🧹 Cleaned up temporary files${NC}"
fi

echo -e "${GREEN}🎉 mycli CLI package installed successfully!${NC}"
echo -e "${BLUE}📁 Package location: $MYCLI_HOME${NC}"
echo -e "${BLUE}🔧 Try running: mycli --help${NC}"
echo -e "${YELLOW}💡 Note: You may need to restart your shell or run 'source ~/.zshrc'${NC}" 