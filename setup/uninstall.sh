#!/bin/zsh

# lie CLI Framework Uninstaller

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

echo -e "${YELLOW}Uninstalling lie CLI Framework...${NC}"

# Remove the wrapper script
if [ -f "$BIN_DIR/lie" ]; then
    rm "$BIN_DIR/lie"
    echo -e "${GREEN}Removed wrapper script from $BIN_DIR${NC}"
fi

# Remove the entire lie home directory
if [ -d "$LIE_HOME" ]; then
    rm -rf "$LIE_HOME"
    echo -e "${GREEN}Removed framework from $LIE_HOME${NC}"
fi

# Remove PATH entry block from .zshrc
ZSHRC="$HOME/.zshrc"
LIE_BLOCK_START="# >>> liecli PATH setup >>>"
LIE_BLOCK_END="# <<< liecli PATH setup <<<"
if [ -f "$ZSHRC" ] && grep -q "$LIE_BLOCK_START" "$ZSHRC"; then
    # Create a backup
    cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d_%H%M%S)"
    # Remove the block
    sed -i.bak "/$LIE_BLOCK_START/,/$LIE_BLOCK_END/d" "$ZSHRC"
    echo -e "${GREEN}Removed liecli PATH block from ~/.zshrc${NC}"
else
    echo -e "${YELLOW}No liecli PATH block found in ~/.zshrc${NC}"
fi

echo -e "${GREEN}✅ lie CLI Framework uninstalled successfully!${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell for changes to take effect${NC}" 