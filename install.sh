#!/bin/zsh

# lie CLI package Installer
# Installs the package to $HOME/.lie

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
LIE_HOME="$HOME/.lie"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installing lie CLI package...${NC}"

# Create lie home directory
mkdir -p "$LIE_HOME"
mkdir -p "$LIE_HOME/modules"
mkdir -p "$LIE_HOME/utils"
mkdir -p "$LIE_HOME/templates"
mkdir -p "$LIE_HOME/config"

# Copy package files
echo -e "${YELLOW}Copying package files...${NC}"
cp -r "$SCRIPT_DIR/package"/* "$LIE_HOME/"

# Make the main lie script executable
chmod +x "$LIE_HOME/lie"

# Create bin directory if not exists
mkdir -p "$BIN_DIR"

# Create the wrapper script
cat > "$BIN_DIR/lie" << 'EOF'
#!/bin/zsh
"$HOME/.lie/lie" "$@"
EOF

chmod +x "$BIN_DIR/lie"

# Add to PATH using a block marker approach
ZSHRC="$HOME/.zshrc"
LIE_BLOCK_START="# >>> liecli PATH setup >>>"
LIE_BLOCK_END="# <<< liecli PATH setup <<<"
LIE_PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

# Remove any existing block
sed -i.bak "/$LIE_BLOCK_START/,/$LIE_BLOCK_END/d" "$ZSHRC"

# Add a newline if the file doesn't end with one
tail -c1 "$ZSHRC" | read -r _ || echo >> "$ZSHRC"

# Append the new block
{
  echo "$LIE_BLOCK_START"
  echo "$LIE_PATH_LINE"
  echo "$LIE_BLOCK_END"
} >> "$ZSHRC"

echo -e "${GREEN}Added $BIN_DIR to PATH in ~/.zshrc using block markers${NC}"

# Create initial config if it doesn't exist
if [ ! -f "$LIE_HOME/config/config.json" ]; then
    cat > "$LIE_HOME/config/config.json" << 'EOF'
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
fi

echo -e "${GREEN}✅ lie CLI package installed successfully!${NC}"
echo -e "${BLUE}package location: $LIE_HOME${NC}"
echo -e "${BLUE}Try running: lie --help${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell or run 'source ~/.zshrc'${NC}" 