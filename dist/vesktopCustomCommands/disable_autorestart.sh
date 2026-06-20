#!/bin/bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/vesktopCustomCommands/config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_restart=.*|auto_restart="false"|' "$CONFIG"
echo "Auto-restart disabled."


