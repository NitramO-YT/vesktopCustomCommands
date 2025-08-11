#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }

# Ensure newline at EOF
sed -i -e '$a\\' "$CONFIG"

if grep -q '^auto_update=' "$CONFIG"; then
  sed -i -e 's|^auto_update=.*|auto_update="true"|' "$CONFIG"
else
  printf '\n%s\n' 'auto_update="true"' >> "$CONFIG"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now vcc-autorepatch.timer 2>/dev/null || true
fi
echo "Auto-update enabled."

