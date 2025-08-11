#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_update=.*|auto_update="true"|' "$CONFIG"
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user enable --now vcc-autorepatch.timer || true
fi
echo "Auto-update enabled."

