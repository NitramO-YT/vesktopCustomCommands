#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_repatch=.*|auto_repatch="false"|' "$CONFIG"
if command -v systemctl >/dev/null 2>&1; then
  # Keep timer running if auto_update is still enabled
  # shellcheck disable=SC1090
  source "$CONFIG" 2>/dev/null || true
  if [ "${auto_update}" = "true" ]; then
    systemctl --user enable --now vcc-autorepatch.timer 2>/dev/null || true
  else
    systemctl --user disable --now vcc-autorepatch.timer 2>/dev/null || true
  fi
fi
echo "Auto-repatch disabled."

