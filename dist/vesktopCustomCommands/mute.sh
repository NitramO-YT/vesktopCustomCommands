#!/bin/bash

# Normalize a path by replacing ~ with $HOME
normalizePath() {
    local input_path="$1"

    # Check if the path starts with ~
    if [[ "$input_path" == ~* ]]; then
        # Replace ~ with $HOME
        echo "${input_path/#\~/$HOME}"
    else
        # Return the path as is if it does not start with ~
        echo "$input_path"
    fi
}

# Define the base directory
DEFAULT_BASE_DIR="$HOME/.config/Vencord/dist"
VENCORD_PATH="$DEFAULT_BASE_DIR"

# Read .config file to get the Vencord path
CONFIG_FILE="$(dirname "$0")/.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    VENCORD_PATH="$(normalizePath "$vencord_path")"
    echo "Vencord path set to: $VENCORD_PATH"
fi

# Check if the path ends with a slash, if not, add it
if [[ "$VENCORD_PATH" != */ ]]; then
    VENCORD_PATH="${VENCORD_PATH}/"
fi

FULL_DIR="${VENCORD_PATH}vesktopCustomCommands"

# Check if Vesktop is running
VESKTOP_PIDS=$(pgrep -aif '(dev\.vencord\.)?vesktop' | awk '{print $1}')

if [ -n "$VESKTOP_PIDS" ]; then
    # Vesktop is active, create the mute file
    MUTE_FILE="$FULL_DIR/mute"

    # Create the directory if it does not exist
    mkdir -p "$FULL_DIR"

    # Create the mute file
    touch "$MUTE_FILE"

    # Check if the file was created successfully
    if [ -f "$MUTE_FILE" ]; then
        echo "File 'mute' created successfully at: $MUTE_FILE"
    else
        echo "Error: Unable to create the 'mute' file."
        exit 1
    fi
else
    echo "Error: Vesktop is not running. The 'mute' file will not be created."
    exit 1
fi