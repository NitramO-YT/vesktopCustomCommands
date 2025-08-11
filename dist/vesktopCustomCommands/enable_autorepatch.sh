#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }

# Ensure newline at EOF
sed -i -e '$a\\' "$CONFIG"

if grep -q '^auto_repatch=' "$CONFIG"; then
  sed -i -e 's|^auto_repatch=.*|auto_repatch="true"|' "$CONFIG"
else
  printf '\n%s\n' 'auto_repatch="true"' >> "$CONFIG"
fi

# Best-effort: create .env for GUI apps under systemd user
ENV_FILE="$HOME/.vesktopCustomCommands/.env"
{
  [ -n "$DISPLAY" ] && echo "DISPLAY=$DISPLAY"
  [ -n "$WAYLAND_DISPLAY" ] && echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
  [ -n "$XDG_RUNTIME_DIR" ] && echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
  [ -n "$DBUS_SESSION_BUS_ADDRESS" ] && echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
} > "$ENV_FILE" 2>/dev/null || true

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now vcc-autorepatch.timer 2>/dev/null || true
fi
echo "Auto-repatch enabled."

