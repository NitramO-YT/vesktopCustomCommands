#!/bin/bash
set -euo pipefail

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

# GUI prompt and session env helpers (same logic as vcc-autorepatch.sh)
prompt_gui_yesno() {
  local title="$1"; local message="$2"
  if command -v kdialog >/dev/null 2>&1; then kdialog --yesno "$message" --title "$title" && return 0 || return 1; fi
  if command -v zenity >/dev/null 2>&1; then zenity --question --text "$message" --title "$title" && return 0 || return 1; fi
  if command -v xmessage >/dev/null 2>&1; then xmessage -buttons Yes:0,No:1 "$message" --title "$title" && return 0 || return 1; fi
  return 2
}

ensure_session_env() {
  local env_file="$HOME/.vesktopCustomCommands/.env"
  [ -f "$env_file" ] || return 0
  # shellcheck disable=SC2046
  export $(grep -E '^(DISPLAY|WAYLAND_DISPLAY|XDG_RUNTIME_DIR|DBUS_SESSION_BUS_ADDRESS)=' "$env_file" | xargs -d '\n') || true
}

# Ensure a dedicated auto-update timer/service exists and matches config
ensure_update_timer_interval_matches() {
  local unit_dir="$HOME/.config/systemd/user"
  local service_file="$unit_dir/vcc-autoupdate.service"
  local timer_file="$unit_dir/vcc-autoupdate.timer"

  mkdir -p "$unit_dir" 2>/dev/null || true

  # If auto_update disabled: turn off timer and return
  if [ "${auto_update:-false}" != "true" ]; then
    if command -v systemctl >/dev/null 2>&1; then
      systemctl --user disable --now vcc-autoupdate.timer 2>/dev/null || true
    fi
    return 0
  fi

  # Desired interval
  local desired_interval="${auto_update_interval:-15m}"

  # Ensure service unit present (idempotent)
  if [ ! -f "$service_file" ]; then
    cat > "$service_file" <<'EOUNIT'
[Unit]
Description=vesktopCustomCommands auto-update service

[Service]
Type=oneshot
ExecStart=%h/.vesktopCustomCommands/vcc-autoupdate.sh
EnvironmentFile=-%h/.vesktopCustomCommands/.env
KillMode=process
EOUNIT
  fi

  # Read current interval if timer exists
  local current_interval=""
  if [ -f "$timer_file" ]; then
    current_interval="$(grep -E '^OnUnitActiveSec=' "$timer_file" | head -n1 | sed -E 's/^OnUnitActiveSec=(.*)/\1/')"
  fi

  # Rewrite timer if missing or interval differs
  if [ ! -f "$timer_file" ] || [ "$current_interval" != "$desired_interval" ]; then
    cat > "$timer_file" <<EOUNIT
[Unit]
Description=Run VCC auto-update periodically

[Timer]
OnBootSec=30s
OnUnitActiveSec=${desired_interval}
Persistent=true

[Install]
WantedBy=timers.target
EOUNIT
    if command -v systemctl >/dev/null 2>&1; then
      systemctl --user daemon-reload 2>/dev/null || true
      systemctl --user enable --now vcc-autoupdate.timer 2>/dev/null || true
    fi
  fi
}

detect_vesktop() {
  DETECTED=""; START_CMD=""; KILL_CMD=""; RUNNING="false"
  if command -v flatpak >/dev/null 2>&1; then
    if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
      DETECTED="flatpak"; FP_BIN="$(command -v flatpak)"; START_CMD="$FP_BIN run dev.vencord.Vesktop"; KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
      if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then RUNNING="true"; fi; return
    fi
  fi
  if command -v vesktop >/dev/null 2>&1; then
    DETECTED="system"; START_CMD="vesktop"; KILL_CMD="pkill -x vesktop || pkill -f vesktop || true"
    if pgrep -x vesktop >/dev/null 2>&1 || pgrep -f '[Vv]esktop' >/dev/null 2>&1; then RUNNING="true"; fi; return
  fi
  PID="$(pgrep -f -n '[Vv]esktop' || true)"; if [ -n "$PID" ] && [ -r "/proc/$PID/exe" ]; then EXE_PATH="$(readlink -f "/proc/$PID/exe" || true)"; if [ -n "$EXE_PATH" ]; then DETECTED="path"; START_CMD="$EXE_PATH"; KILL_CMD="kill $PID || true"; RUNNING="true"; return; fi; fi
}

restart_vesktop() {
  local was_running="$1"
  detect_vesktop; ensure_session_env
  if [ -z "$DETECTED" ] || [ "$was_running" != "true" ]; then return 1; fi
  eval "$KILL_CMD" 2>/dev/null || true
  for _ in $(seq 1 20); do
    if command -v flatpak >/dev/null 2>&1 && [ "$DETECTED" = "flatpak" ]; then
      if ! flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then break; fi
    else
      if ! pgrep -f '[Vv]esktop' >/dev/null 2>&1; then break; fi
    fi
    sleep 0.5
  done
  nohup bash -lc "$START_CMD" >/dev/null 2>&1 & disown
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

start_vesktop_if_requested() {
  detect_vesktop; ensure_session_env
  if [ -z "$DETECTED" ]; then return 1; fi
  nohup bash -lc "$START_CMD" >/dev/null 2>&1 & disown
  return 0
}

REPO_BASE="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main"
REMOTE_CUSTOMCODE="$REPO_BASE/dist/vencord/customCode.js"

update_file() {
  local url="$1" path="$2"
  mkdir -p "$(dirname "$path")"
  curl -fsSL "$url" -o "$path"
}

perform_update_js() {
  local vpath
  vpath="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")"
  mkdir -p "$vpath/vesktopCustomCommands"
  update_file "$REMOTE_CUSTOMCODE" "$vpath/vesktopCustomCommands/customCode.js"
}

perform_update_scripts_silent() {
  mkdir -p "$HOME/.vesktopCustomCommands"
  update_file "$REPO_BASE/dist/vesktopCustomCommands/mute.sh" "$HOME/.vesktopCustomCommands/mute.sh"; chmod +x "$HOME/.vesktopCustomCommands/mute.sh" || true
  update_file "$REPO_BASE/dist/vesktopCustomCommands/deafen.sh" "$HOME/.vesktopCustomCommands/deafen.sh"; chmod +x "$HOME/.vesktopCustomCommands/deafen.sh" || true
  # Optionally refresh local helpers too
  for helper in vcc-autorepatch.sh vcc-repatch-interactive.sh vcc-autoupdate.sh; do
    update_file "$REPO_BASE/dist/vesktopCustomCommands/$helper" "$HOME/.vesktopCustomCommands/$helper" 2>/dev/null || true
    chmod +x "$HOME/.vesktopCustomCommands/$helper" 2>/dev/null || true
  done
}

# Compare remote and local customCode.js
needs_update_js() {
  local vpath local_file tmp_remote
  vpath="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")"
  local_file="$vpath/vesktopCustomCommands/customCode.js"
  tmp_remote="$(mktemp)"
  curl -fsSL "$REMOTE_CUSTOMCODE" -o "$tmp_remote" || { rm -f "$tmp_remote"; return 1; }
  if [ ! -f "$local_file" ]; then rm -f "$tmp_remote"; return 0; fi
  if command -v sha256sum >/dev/null 2>&1; then
    local local_sum remote_sum
    local_sum="$(sha256sum "$local_file" | awk '{print $1}')" || local_sum=""
    remote_sum="$(sha256sum "$tmp_remote" | awk '{print $1}')" || remote_sum=""
    rm -f "$tmp_remote"
    [ "$local_sum" != "$remote_sum" ]; return $?
  else
    local local_size remote_size
    local_size="$(stat -c%s "$local_file" 2>/dev/null || echo 0)"
    remote_size="$(stat -c%s "$tmp_remote" 2>/dev/null || echo 0)"
    rm -f "$tmp_remote"
    [ "$local_size" != "$remote_size" ]; return $?
  fi
}

# Keep timer in sync at every invocation
ensure_update_timer_interval_matches

[ "${auto_update:-false}" = "true" ] || exit 0

ensure_session_env

# Always refresh local scripts silently (no GUI needed)
perform_update_scripts_silent || true

WAS_RUNNING=false
if command -v flatpak >/dev/null 2>&1; then if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then WAS_RUNNING=true; fi; fi
if pgrep -x vesktop >/dev/null 2>&1 || pgrep -f '[Vv]esktop' >/dev/null 2>&1; then WAS_RUNNING=true; fi

if needs_update_js; then
  if prompt_gui_yesno "VCC for Vesktop/Vencord update" "A new VCC JavaScript file is available. Do you want to install it now?"; then
    perform_update_js || exit 1
    # Propose restart/start depending on state
    if [ "$WAS_RUNNING" = true ]; then
      if prompt_gui_yesno "VCC for Vesktop/Vencord update" "Update installed. Do you want to restart Vesktop now?"; then
        restart_vesktop "true" || true
      fi
    else
      if prompt_gui_yesno "VCC for Vesktop/Vencord update" "Update installed. Do you want to start Vesktop now?"; then
        start_vesktop_if_requested || true
      fi
    fi
  fi
fi

exit 0

