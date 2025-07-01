#!/bin/zsh

# mycli CLI - Main Dispatcher
# Generated from mycli.json

set -e

# Load utilities
source "$(dirname $0)/utils.sh"

# Load commands
source "$(dirname $0)/commands.sh"

# Load config
CONFIG_FILE="$(dirname $0)/mycli.json"

# Parse command line
COMMAND="$1"
SUBCOMMAND="$2"
shift

# Show help if no arguments provided
if [ $# -eq 0 ] && [ -z "$COMMAND" ]; then
    help
    exit 0
fi

# Route commands
case "$COMMAND" in
    help|--help|-h)
        help "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'mycli help' for available commands."
        exit 1
        ;;
esac
