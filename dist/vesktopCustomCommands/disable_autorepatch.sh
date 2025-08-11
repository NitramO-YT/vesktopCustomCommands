#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_repatch=.*|auto_repatch="false"|' "$CONFIG"
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user disable --now vcc-autorepatch.timer 2>/dev/null || true
fi
echo "Auto-repatch disabled."

