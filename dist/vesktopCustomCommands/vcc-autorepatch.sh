#!/bin/bash

# Lock to avoid concurrent runs (use runtime dir so leftover files don't clutter $HOME)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_DIR="$RUNTIME_DIR/vcc"
mkdir -p "$LOCK_DIR" 2>/dev/null || true
LOCK_FILE="$LOCK_DIR/VCC_Autorepatch.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0
# Best-effort cleanup of the lock file when this process exits
trap 'rm -f "$LOCK_FILE" >/dev/null 2>&1 || true' EXIT

CONFIG="$HOME/.vesktopCustomCommands/.config"
[ -f "$CONFIG" ] || exit 0
# shellcheck disable=SC1090
source "$CONFIG"

normalizePath() {
  local input_path="$1"
  if [[ "$input_path" == ~* ]]; then
    echo "${input_path/#\~/$HOME}"
  else
    echo "$input_path"
  fi
}

# Ensure customCode.js exists like the installateur does
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
      DETECTED="flatpak"
      FP_BIN="$(command -v flatpak)"; ARCH="$(uname -m)"
      START_CMD="$FP_BIN run dev.vencord.Vesktop"
      KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
      if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then RUNNING="true"; fi
      return
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

prompt_gui_yesno() {
  local title="$1"
  local message="$2"
  if command -v kdialog >/dev/null 2>&1; then
    kdialog --yesno "$message" --title "$title" && return 0 || return 1
  fi
  if command -v zenity >/dev/null 2>&1; then
    zenity --question --text "$message" --title "$title" && return 0 || return 1
  fi
  if command -v xmessage >/dev/null 2>&1; then
    xmessage -buttons Yes:0,No:1 "$message" --title "$title" && return 0 || return 1
  fi
  return 2
}

ensure_session_env() {
  local env_file="$HOME/.vesktopCustomCommands/.env"
  [ -f "$env_file" ] || return 0
  # shellcheck disable=SC2046
  export $(grep -E '^(DISPLAY|WAYLAND_DISPLAY|XDG_RUNTIME_DIR|DBUS_SESSION_BUS_ADDRESS)=' "$env_file" | xargs -d '\n') || true
}

launch_terminal_cmd() {
  local cmd="$1"
  ensure_session_env
  if command -v konsole >/dev/null 2>&1; then nohup konsole -e bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v gnome-terminal >/dev/null 2>&1; then nohup gnome-terminal -- bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v xfce4-terminal >/dev/null 2>&1; then nohup xfce4-terminal -e "bash -lc '$cmd'" >/dev/null 2>&1 & disown; return; fi
  if command -v kitty >/dev/null 2>&1; then nohup kitty bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v alacritty >/dev/null 2>&1; then nohup alacritty -e bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v wezterm >/dev/null 2>&1; then nohup wezterm start -- bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v tilix >/dev/null 2>&1; then nohup tilix -q -e bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v mate-terminal >/dev/null 2>&1; then nohup mate-terminal -- bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v lxterminal >/dev/null 2>&1; then nohup lxterminal -e bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
  if command -v xterm >/dev/null 2>&1; then nohup xterm -e bash -lc "$cmd" >/dev/null 2>&1 & disown; return; fi
}

is_patched() {
  local preload_file="$1"
  # Identique à l'installateur: si la ligne d'origine est encore présente, ce n'est PAS patché
  if grep -q 'document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})' "$preload_file"; then
    return 1
  fi
  return 0
}

patch_preload() {
  local preload_file="$1"
  local sample_url="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main/dist/vencord/vencordDesktopPreload_sample.js"
  # Make sure the custom code file exists before patching, exactly like the installateur
  ensure_custom_code || true
  CODE_TO_INJECT=$(curl -s -w "%{http_code}" "$sample_url") || return 1
  HTTP_RESPONSE="${CODE_TO_INJECT: -3}"; CODE_TO_INJECT="${CODE_TO_INJECT%???}"
  if [ "$HTTP_RESPONSE" -ne 200 ] || [ -z "$CODE_TO_INJECT" ]; then
    return 1
  fi

  if grep -q 'document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})' "$preload_file"; then
    sed -i "s|document\.addEventListener(\"DOMContentLoaded\",()=>document\.documentElement\.appendChild(r),{once:!0})|document.addEventListener(\"DOMContentLoaded\",()=>{document.documentElement.appendChild(r);${CODE_TO_INJECT}},{once:!0})|" "$preload_file"
    return $?
  fi

  return 1
}

restart_vesktop() {
  local was_running="$1"
  detect_vesktop
  ensure_session_env
  if [ -z "$DETECTED" ] || [ "$was_running" != "true" ]; then
    return 1
  fi

  # Kill gracefully
  eval "$KILL_CMD" 2>/dev/null || true
  # Wait until it fully stops (max ~10s)
  for _ in $(seq 1 20); do
    if command -v flatpak >/dev/null 2>&1 && [ "$DETECTED" = "flatpak" ]; then
      if ! flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then break; fi
    else
      if ! pgrep -f '[Vv]esktop' >/dev/null 2>&1; then break; fi
    fi
    sleep 0.5
  done

  # Start again
  nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown

  # Best-effort: verify it started (max ~5s)
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

timeTriedGuiPrompt=0
tryGuiPrompt() {
  if prompt_gui_yesno "VCC for Vesktop/Vencord repatch" "A repatch is required. Do you want to apply it now?"; then
    if patch_preload "$PRELOAD_FILE"; then
      if prompt_gui_yesno "VCC for Vesktop/Vencord repatch" "Repatch done. Do you want to restart Vesktop now?"; then
        # In interactive mode, we restart explicitly if the user accepts.
        # If restart fails, open the interactive helper in a terminal as fallback.
        restart_vesktop "true" || launch_terminal_cmd "$HOME/.vesktopCustomCommands/vcc-repatch-interactive.sh"
      fi
    fi
  else
    # Ask to disable auto_repatch
    if prompt_gui_yesno "VCC for Vesktop/Vencord repatch" "Disable auto-repatch?"; then
      sed -i -e 's|^auto_repatch=.*|auto_repatch="false"|' "$CONFIG"
    else
      if [ "$timeTriedGuiPrompt" -lt 3 ]; then
        timeTriedGuiPrompt=$((timeTriedGuiPrompt + 1))
        tryGuiPrompt
      else
        # third time :
        launch_terminal_cmd "$HOME/.vesktopCustomCommands/vcc-repatch-interactive.sh"
      fi
    fi
  fi
}

main() {
  AUTO_UPDATE_ACTIVE=false
  if [ "${auto_update}" = "true" ]; then
    AUTO_UPDATE_ACTIVE=true
  fi
  if [ "${auto_repatch}" != "true" ] && [ "$AUTO_UPDATE_ACTIVE" != true ]; then
    exit 0
  fi
  PRELOAD_FILE="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")/vencordDesktopPreload.js"
  if [ ! -f "$PRELOAD_FILE" ]; then
    PRELOAD_FILE=""
  fi
  if [ "$AUTO_UPDATE_ACTIVE" = true ] && [ -x "$HOME/.vesktopCustomCommands/vcc-autoupdate.sh" ]; then
    "$HOME/.vesktopCustomCommands/vcc-autoupdate.sh" || true
  fi
  if [ -n "$PRELOAD_FILE" ] && [ -f "$PRELOAD_FILE" ]; then
    if is_patched "$PRELOAD_FILE"; then
      exit 0
    fi
    WAS_RUNNING=false
    if command -v flatpak >/dev/null 2>&1; then
      if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then WAS_RUNNING=true; fi
    fi
    if pgrep -x vesktop >/dev/null 2>&1 || pgrep -f '[Vv]esktop' >/dev/null 2>&1; then WAS_RUNNING=true; fi
    if [ "${auto_repatch}" = "true" ]; then
      if [ "${auto_restart}" = "true" ]; then
        if patch_preload "$PRELOAD_FILE"; then
          restart_vesktop "$WAS_RUNNING" || true
        else
          # Inform user and offer interactive helper
          if prompt_gui_yesno "VCC for Vesktop/Vencord repatch" "The repatch failed. Open the repatch assistant via terminal?"; then
            launch_terminal_cmd "$HOME/.vesktopCustomCommands/vcc-repatch-interactive.sh"
          fi
        fi
      else
        # Try GUI prompt first
        tryGuiPrompt
      fi
    fi
  fi
}

main "$@"