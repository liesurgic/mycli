#!/bin/bash

# read-config.sh - Helper functions for reading CLI config JSON
# Usage: source this file in other scripts to access config readers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Read all commands (returns base64-encoded JSON for each command)
read_commands() {
    local config_file="$1"
    read_json_values "$config_file" "commands"
}

# Read flags for a given command (by index)
read_command_flags() {
    local config_file="$1"
    local command_index="$2"
    jq -r ".commands[$command_index].flags[] | @base64" "$config_file" 2>/dev/null
}

# Read the module/CLI name
read_module_name() {
    local config_file="$1"
    read_json_value "$config_file" "name"
}

# Read the module/CLI description
read_module_description() {
    local config_file="$1"
    read_json_value "$config_file" "description"
}

# Extract command name from base64-encoded command JSON
read_command_name() {
    local command_b64="$1"
    local command_json=$(echo "$command_b64" | base64 -d)
    echo "$command_json" | jq -r '.name // empty'
}

# Extract command description from base64-encoded command JSON
read_command_description() {
    local command_b64="$1"
    local command_json=$(echo "$command_b64" | base64 -d)
    echo "$command_json" | jq -r '.description // empty'
}

# Extract command info as pipe-separated string (name|description)
read_command_info() {
    local command_b64="$1"
    local command_json=$(echo "$command_b64" | base64 -d)
    local cmd_name=$(echo "$command_json" | jq -r '.name // empty')
    local cmd_desc=$(echo "$command_json" | jq -r '.description // empty')
    echo "$cmd_name|$cmd_desc"
}

# Extract flag info from base64-encoded flag JSON
extract_flag_info() {
    local flag_b64="$1"
    local flag_json=$(echo "$flag_b64" | base64 -d)
    
    local flag_name=$(echo "$flag_json" | jq -r '.name // empty')
    local flag_shorthand=$(echo "$flag_json" | jq -r '.shorthand // empty')
    local flag_desc=$(echo "$flag_json" | jq -r '.description // empty')
    
    echo "$flag_name|$flag_shorthand|$flag_desc"
}

# Get flag names for a specific command by name
read_command_flag_names() {
    local config_file="$1"
    local command_name="$2"
    
    # Use jq to find the command by name and extract flag names
    jq -r --arg cmd_name "$command_name" '
        .commands[] | 
        select(.name == $cmd_name) | 
        .flags[]?.name // empty
    ' "$config_file" 2>/dev/null
}

# Get all command names from config
read_command_names() {
    local config_file="$1"
    
    # Use jq to extract all command names
    jq -r '.commands[]?.name // empty' "$config_file" 2>/dev/null
}

# You can add more helpers as needed, e.g. for version, author, etc. 