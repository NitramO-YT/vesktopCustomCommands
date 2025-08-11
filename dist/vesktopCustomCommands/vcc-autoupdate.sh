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

REPO_BASE="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main"

update_file() {
  local url="$1" path="$2"
  mkdir -p "$(dirname "$path")"
  curl -fsSL "$url" -o "$path"
}

perform_update() {
  # Update vencord custom code and preload samples
  if [ -n "${vencord_path:-}" ]; then
    local vpath="$(normalizePath "$vencord_path")"
    mkdir -p "$vpath/vesktopCustomCommands"
    update_file "$REPO_BASE/dist/vencord/customCode.js" "$vpath/vesktopCustomCommands/customCode.js"
  fi
  # Update local scripts and helpers
  mkdir -p "$HOME/.vesktopCustomCommands"
  update_file "$REPO_BASE/dist/vesktopCustomCommands/mute.sh" "$HOME/.vesktopCustomCommands/mute.sh"
  chmod +x "$HOME/.vesktopCustomCommands/mute.sh" || true
  update_file "$REPO_BASE/dist/vesktopCustomCommands/deafen.sh" "$HOME/.vesktopCustomCommands/deafen.sh"
  chmod +x "$HOME/.vesktopCustomCommands/deafen.sh" || true
}

# Version check via README etag or commit hash would be ideal, but we keep it simple:
# Compare remote and local customCode.js checksums when available.

needs_update() {
  if [ -z "${vencord_path:-}" ]; then
    return 1
  fi
  local vpath="$(normalizePath "$vencord_path")"
  local local_file="$vpath/vesktopCustomCommands/customCode.js"
  local tmp_remote="$(mktemp)"
  curl -fsSL "$REPO_BASE/dist/vesktopCustomCommands/customCode.js" -o "$tmp_remote" || { rm -f "$tmp_remote"; return 1; }
  if [ ! -f "$local_file" ]; then
    rm -f "$tmp_remote"; return 0
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    local local_sum remote_sum
    local_sum="$(sha256sum "$local_file" | awk '{print $1}')"
    remote_sum="$(sha256sum "$tmp_remote" | awk '{print $1}')"
    rm -f "$tmp_remote"
    [ "$local_sum" != "$remote_sum" ]
    return $?
  else
    # Fallback: size compare
    local local_size remote_size
    local_size="$(stat -c%s "$local_file" 2>/dev/null || echo 0)"
    remote_size="$(stat -c%s "$tmp_remote" 2>/dev/null || echo 0)"
    rm -f "$tmp_remote"
    [ "$local_size" != "$remote_size" ]
    return $?
  fi
}

[ "${auto_update}" = "true" ] || exit 0

# Rate limiting via systemd timer interval in install.sh; we just run once here
if needs_update; then
  perform_update || exit 1
fi

exit 0

