#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_update=.*|auto_update="false"|' "$CONFIG"
if command -v systemctl >/dev/null 2>&1; then
  # Timer may still be needed for auto_repatch; only stop if both disabled
  source "$CONFIG"
  if [ "${auto_repatch}" != "true" ]; then
    systemctl --user disable --now vcc-autorepatch.timer 2>/dev/null || true
  fi
fi
echo "Auto-update disabled."

