#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_restart=.*|auto_restart="false"|' "$CONFIG"
echo "Auto-restart disabled."


