  
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

cat > "cli.json" << EOF
{
  "name": "",
  "description": "",
  "version": "1.0.0",
  "commands": [
    {
      "name": "",
      "description": "",
      "flags": [
        {
          "description": "",
          "name": "",
          "shorthand": "",
        }
      ]
    }
  ]
}
EOF

print_success "cli.json"
