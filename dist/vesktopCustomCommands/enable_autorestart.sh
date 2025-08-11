#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }
sed -i -e 's|^auto_restart=.*|auto_restart="true"|' "$CONFIG"
# If auto_repatch is enabled, make sure the timer is running
if command -v systemctl >/dev/null 2>&1; then
  # shellcheck disable=SC1090
  source "$CONFIG" 2>/dev/null || true
  if [ "${auto_repatch}" = "true" ]; then
    systemctl --user enable --now vcc-autorepatch.timer 2>/dev/null || true
  fi
fi
echo "Auto-restart enabled."


