#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_repatch=.*|auto_repatch="true"|' "$CONFIG"
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user enable --now vcc-autorepatch.timer || true
fi
echo "Auto-repatch enabled."

