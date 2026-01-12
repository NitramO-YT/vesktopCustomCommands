#!/bin/bash
CONFIG="$HOME/.vesktopCustomCommands/.config"

normalizePath() {
  local input_path="$1"
  if [[ "$input_path" == ~* ]]; then
    echo "${input_path/#\~/$HOME}"
  else
    echo "$input_path"
  fi
}

# Load session environment for GUI apps (Wayland/X11/DBus) if available
ensure_session_env() {
  local env_file="$HOME/.vesktopCustomCommands/.env"
  [ -f "$env_file" ] || return 0
  # shellcheck disable=SC2046
  export $(grep -E '^(DISPLAY|WAYLAND_DISPLAY|XDG_RUNTIME_DIR|DBUS_SESSION_BUS_ADDRESS)=' "$env_file" | xargs -d '\n') || true
}

 

# Ensure customCode.js exists (same behavior as installer)
ensure_custom_code() {
  local vpath
  vpath="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")"
  local vcc_dir="$vpath/vesktopCustomCommands"
  local code_file="$vcc_dir/customCode.js"
  local repo_code_url="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main/dist/vencord/customCode.js"
  if [ ! -f "$code_file" ]; then
    mkdir -p "$vcc_dir" || return 1
    curl -fsSL "$repo_code_url" -o "$code_file" || return 1
  fi
  return 0
}

detect_vesktop() {
  DETECTED=""; START_CMD=""; KILL_CMD=""
  RUNNING="false"
  if command -v flatpak >/dev/null 2>&1; then
    if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
      DETECTED="flatpak"; FP_BIN="$(command -v flatpak)"; ARCH="$(uname -m)"
      START_CMD="$FP_BIN run dev.vencord.Vesktop"
      KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"; return
    fi
  fi
  if command -v vesktop >/dev/null 2>&1; then
    DETECTED="system"; START_CMD="vesktop"; KILL_CMD="pkill -x vesktop || pkill -f vesktop || true"; return
  fi
  PID="$(pgrep -f -n '[Vv]esktop' || true)"
  if [ -n "$PID" ] && [ -r "/proc/$PID/exe" ]; then
    EXE_PATH="$(readlink -f "/proc/$PID/exe" || true)"
    if [ -n "$EXE_PATH" ]; then
      DETECTED="path"; START_CMD="$EXE_PATH"; KILL_CMD="kill $PID || true"; return
    fi
  fi
}

is_patched() {
  local main_file="$1"
  # Universal detection: check for our VCC signature in the injection code
  if grep -q '\[VesktopCustomCommands\]' "$main_file"; then
    return 0
  fi
  return 1
}

patch_main() {
  local main_file="$1"
  local sample_url="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main/dist/vencord/vencordDesktopMain_sample.js"
  CODE_TO_INJECT=$(curl -s -w "%{http_code}" "$sample_url") || return 1
  HTTP_RESPONSE="${CODE_TO_INJECT: -3}"; CODE_TO_INJECT="${CODE_TO_INJECT%???}"
  if [ "$HTTP_RESPONSE" -ne 200 ] || [ -z "$CODE_TO_INJECT" ]; then
    echo "Error: Unable to download code sample (HTTP $HTTP_RESPONSE)" >&2
    return 1
  fi

  # Universal injection: inject before the source map (works with all Vencord versions)
  if grep -q '//# sourceURL=' "$main_file"; then
    sed -i "s|//# sourceURL=|${CODE_TO_INJECT}//# sourceURL=|" "$main_file"
    return $?
  fi

  return 1
}

restart_vesktop() {
  detect_vesktop
  ensure_session_env
  if [ -z "$DETECTED" ]; then
    return 1
  fi
  eval "$KILL_CMD" 2>/dev/null || true
  # Wait until fully stopped
  for _ in $(seq 1 20); do
    if command -v flatpak >/dev/null 2>&1 && [ "$DETECTED" = "flatpak" ]; then
      if ! flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then break; fi
    else
      if ! pgrep -f '[Vv]esktop' >/dev/null 2>&1; then break; fi
    fi
    sleep 0.5
  done
  # Fully detach so closing the terminal won't kill Vesktop
  if command -v setsid >/dev/null 2>&1; then
    setsid -f bash -lc "$START_CMD" >/dev/null 2>&1 || true
  else
    nohup bash -lc "$START_CMD" >/dev/null 2>&1 & disown
  fi
  # Verify
  for _ in $(seq 1 10); do
    if command -v flatpak >/dev/null 2>&1 && [ "$DETECTED" = "flatpak" ]; then
      if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then return 0; fi
    else
      if pgrep -f '[Vv]esktop' >/dev/null 2>&1; then return 0; fi
    fi
    sleep 0.5
  done
  return 1
}

# Bootstrap environment
ensure_session_env

[ -f "$CONFIG" ] || { echo "Missing config at $CONFIG"; exit 1; }
# shellcheck disable=SC1090
source "$CONFIG"
MAIN_FILE="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")/vencordDesktopMain.js"


echo "vesktopCustomCommands: a repatch is required."
read -p "Do you want to repatch now? (y/n) " -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  ensure_custom_code || true
  if patch_main "$MAIN_FILE"; then
    echo "Repatch done."
    read -p "Do you want to restart Vesktop now? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      restart_vesktop || echo "Unable to restart Vesktop automatically."
      echo "Press any key to close..."; read -n 1 -s -r
    fi
    exit 0
  else
    echo "Repatch failed."
    echo "Press any key to close..."; read -n 1 -s -r
    exit 1
  fi
else
  echo "Proposing to disable auto-repatch."
  read -p "Do you confirm disabling auto-repatch? (y/n) " -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sed -i -e 's|^auto_repatch=.*|auto_repatch="false"|' "$CONFIG"
    echo "Auto-repatch disabled."
    echo "Press any key to close..."; read -n 1 -s -r
    exit 0
  else
    echo "Cancelled. No settings changed."
    echo "Press any key to close..."; read -n 1 -s -r
    exit 0
  fi
fi


