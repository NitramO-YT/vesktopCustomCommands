#!/bin/bash

# Normalize a path by replacing ~ with $HOME
normalizePath() {
    local input_path="$1"

    # Check if the path starts with ~
    if [[ "$input_path" == ~* ]]; then
        # Replace ~ with $HOME
        echo "${input_path/#\~/$HOME}"
    else
        # Return the path as is if it does not start with ~
        echo "$input_path"
    fi
}

# Download a file from a URL
download_file() {
    local url=$1
    local dest=$2
    echo "Downloading \"$url\" to \"$dest\"..."
    curl -s -o "$dest" "$url"
    if [ $? -ne 0 ]; then
        echo "Error: Unable to download $url"
        exit 1
    else 
        echo "Downloaded \"$url\" to \"$dest\" successfully"
    fi
}

# Detect Vesktop variant and prepare restart command
detect_vesktop() {
    DETECTED=""
    START_CMD=""
    KILL_CMD=""

    # Prefer explicit flatpak if present
    if command -v flatpak >/dev/null 2>&1; then
        if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
            DETECTED="flatpak"
            FP_BIN="$(command -v flatpak)"
            ARCH="$(uname -m)"
            START_CMD="$FP_BIN run --branch=stable --arch=$ARCH --command=startvesktop --file-forwarding dev.vencord.Vesktop @@u %U @@"
            KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
            return
        fi
    fi

    # System package (vesktop in PATH)
    if command -v vesktop >/dev/null 2>&1; then
        DETECTED="system"
        START_CMD="vesktop"
        KILL_CMD="pkill -x vesktop || pkill -f vesktop || true"
        return
    fi

    # Fallback: detect a running AppImage/tarball by PID and reuse its path
    PID="$(pgrep -f -n '[Vv]esktop' || true)"
    if [ -n "$PID" ] && [ -r "/proc/$PID/exe" ]; then
        EXE_PATH="$(readlink -f "/proc/$PID/exe" || true)"
        if [ -n "$EXE_PATH" ]; then
            DETECTED="path"
            START_CMD="$EXE_PATH"
            KILL_CMD="kill $PID || true"
            return
        fi
    fi
}

offer_restart_vesktop() {
    detect_vesktop
    if [ -n "$DETECTED" ]; then
        echo "We detected Vesktop variant: $DETECTED"
        read -p 'Do you want us to restart Vesktop now? (y/n) ' -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            eval "$KILL_CMD"
            sleep 1
            nohup bash -c "$START_CMD" >/dev/null 2>&1 &
            disown
            echo 'Vesktop was restarted successfully.'
            return
        fi
    fi
    echo '⚠️ Please restart Vesktop to apply the changes'
}

# Ask to the user if he accepts the automatic installation
read -p 'Do you want to automatically install "vesktopCustomCommands"? (y/n) ' -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "For a manual installation, please refer to the README.md file in the repository or follow the next steps:"
    echo "1. Download the 'dist' folder from the repository or its content."
    echo "2. 'dist' is separated in two parts:"
    echo "    - 'vencord' folder contains the files to inject in the Vencord preload file."
    echo "    - 'vesktopCustomCommands' folder contains the scripts to mute/deafen and the '.config' file."
    echo "3. You can make a backup of your Vencord preload file (usually located in '~/.config/Vencord/dist/vencordDesktopPreload.js' so 'cp ~/.config/Vencord/dist/vencordDesktopPreload.js ~/.config/Vencord/dist/vencordDesktopPreload.js.bak') or not, if you want to restore it later you can delete the file and start Vesktop to recreate it."
    echo "4. Either inject the content of 'vencordDesktopPreload_sample.js' in your Vencord preload file (usually located in '~/.config/Vencord/dist/vencordDesktopPreload.js') by replacing the line 'document.addEventListener(\"DOMContentLoaded\",()=>document.documentElement.appendChild(r),{once:!0})' by 'document.addEventListener(\"DOMContentLoaded\",()=>document.documentElement.appendChild(r);(PRELOAD SAMPLE FILE CONTENT HERE),{once:!0})' and replace '(PRELOAD SAMPLE FILE CONTENT HERE)' by the content of 'vencordDesktopPreload_sample.js', or replace the whole file with the provided 'vencordDesktopPreload.js' (*NOT RECOMMENDED, as in the event of a Vesktop update, if VCC has not been updated since then, it is less reliable, and this file may be obsolete*.)."
    echo "5. Make a dir 'vesktopCustomCommands' in your Vencord path (usually located in '~/.config/Vencord/dist/') and put the file 'customCode.js' in it."
    echo "6. Make a dir '~/.vesktopCustomCommands' and put the files 'mute.sh' and 'deafen.sh' in it."
    echo "7. Add permissions to the scripts 'mute.sh' and 'deafen.sh':"
    echo "    chmod +x ~/.vesktopCustomCommands/mute.sh"
    echo "    chmod +x ~/.vesktopCustomCommands/deafen.sh"
    echo "8. Put the '.config' file in '~/.vesktopCustomCommands' and update the 'vencord_path' variable with your Vencord path if needed."
    echo "9. Restart Vesktop to apply the changes."
    echo "10. Configure a custom global shortcut in your system to call the scripts 'mute.sh' and 'deafen.sh' in '~/.vesktopCustomCommands/' folder."
    echo "    - 'mute.sh' to mute yourself. '~/.vesktopCustomCommands/mute.sh'"
    echo "    - 'deafen.sh' to deafen yourself. '~/.vesktopCustomCommands/deafen.sh'"
    echo "11. Enjoy your new global shortcuts to mute and deafen yourself!"

    exit 0
fi

DEFAULT_VENCORD_PATH="~/.config/Vencord/dist/"
VENCORD_PATH=$DEFAULT_VENCORD_PATH

# Ask for validation of Vencord path
read -p 'Is the path of Vencord of Vesktop "'${VENCORD_PATH}'"? (y/n) ' -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    # Ask for the path of Vencord (with pre-filled "~/.config/Vencord/dist/" so the user don't have to re type it)
    read -p 'Please enter the path of Vencord of Vesktop: ' -i "${VENCORD_PATH}" -e vencordPath
    VENCORD_PATH=$vencordPath
fi

# Check if the path exists
if [ ! -d "$(normalizePath "$VENCORD_PATH")" ]; then
    echo 'Error: The path "'${VENCORD_PATH}'" does not exist'
    echo 'Trying with the default path "'${DEFAULT_VENCORD_PATH}'"...'
    if [ ! -d "$(normalizePath "$DEFAULT_VENCORD_PATH")" ]; then
        echo "Error: The default path ${DEFAULT_VENCORD_PATH} does not exist"
        exit 1
    else
        echo 'Default path "'${DEFAULT_VENCORD_PATH}'" found!'
        echo 'Using the default path "'${DEFAULT_VENCORD_PATH}'"'
        VENCORD_PATH=$DEFAULT_VENCORD_PATH
    fi
fi

# Check if the path ends with a slash, if not, add it
if [[ "$VENCORD_PATH" != */ ]]; then
    VENCORD_PATH="${VENCORD_PATH}/"
fi

# DESTINATION PATHS
VENCORD_PATH_VCC="${VENCORD_PATH}vesktopCustomCommands/"
VENCORD_PRELOAD_FILE="${VENCORD_PATH}vencordDesktopPreload.js"
VENCORD_VCC_CUSTOM_CODE_FILE="${VENCORD_PATH_VCC}customCode.js"

VCC_PATH="$HOME/.vesktopCustomCommands/"
VCC_MUTE_PATH="${VCC_PATH}mute.sh"
VCC_DEAFEN_PATH="${VCC_PATH}deafen.sh"
VCC_CONFIG_PATH="${VCC_PATH}.config"

# SOURCE PATHS
REPOSITORY_SOURCE="https://raw.githubusercontent.com/"
VCC_REPOSITORY_USER="NitramO-YT"
VCC_REPOSITORY_NAME="vesktopCustomCommands"
VCC_REPOSITORY_BRANCH="main"
VCC_REPOSITORY_BASE="${REPOSITORY_SOURCE}${VCC_REPOSITORY_USER}/${VCC_REPOSITORY_NAME}/${VCC_REPOSITORY_BRANCH}/"
VCC_REPOSITORY_DIST="${VCC_REPOSITORY_BASE}dist/"

VCC_REPOSITORY_VENCORD_PATH="${VCC_REPOSITORY_DIST}Vencord/"
VCC_REPOSITORY_VENCORD_PRELOAD_FILE="${VCC_REPOSITORY_VENCORD_PATH}vencordDesktopPreload.js"
VCC_REPOSITORY_VENCORD_PRELOAD_FILE_SAMPLE="${VCC_REPOSITORY_VENCORD_PATH}vencordDesktopPreload_sample.js"
VCC_REPOSITORY_VCC_CUSTOM_CODE_FILE="${VCC_REPOSITORY_VENCORD_PATH}customCode.js"

VCC_REPOSITORY_VCC_PATH="${VCC_REPOSITORY_DIST}vesktopCustomCommands/"
VCC_REPOSITORY_VCC_MUTE_PATH="${VCC_REPOSITORY_VCC_PATH}mute.sh"
VCC_REPOSITORY_VCC_DEAFEN_PATH="${VCC_REPOSITORY_VCC_PATH}deafen.sh"
VCC_REPOSITORY_VCC_CONFIG_PATH="${VCC_REPOSITORY_VCC_PATH}.config"



# Check if the Vencord preload file exists and try to patch it
PRELOAD_FILE_PATCHED=false
if [ ! -f "$(normalizePath "$VENCORD_PRELOAD_FILE")" ]; then
    read -p 'The preload file of Vencord of Vesktop does not exist, do you want to try to make it automatically? (y/n) ' -n 1 -r
    echo    # move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting Vesktop..."
        vesktop &
        sleep 5
        echo "Closing Vesktop..."
        killall vesktop
        if [ ! -f "$(normalizePath "$VENCORD_PRELOAD_FILE")" ]; then
            echo "Vesktop was not able to create the preload file, using the reference file from the repository instead"
            download_file "$VCC_REPOSITORY_VENCORD_PRELOAD_FILE" "$(normalizePath "$VENCORD_PRELOAD_FILE")"
            PRELOAD_FILE_PATCHED=true
            echo "The preload file was patched successfully"
        fi
    else
        echo "Please start Vesktop and wait for the preload file to be created, and then run the script again"
        exit 0
    fi
fi

# Patch the Vencord preload file if it was not patched before
if [ "$PRELOAD_FILE_PATCHED" = false ]; then
    echo "Trying to patch the Vencord preload file..."
    echo "Downloading the code sample to inject from the repository..."

    # Download the code sample to inject from the repository
    CODE_TO_INJECT=$(curl -s -w "%{http_code}" "$VCC_REPOSITORY_VENCORD_PRELOAD_FILE_SAMPLE")
    HTTP_RESPONSE="${CODE_TO_INJECT: -3}"
    CODE_TO_INJECT="${CODE_TO_INJECT%???}"

    if [ "$HTTP_RESPONSE" -ne 200 ] || [ -z "$CODE_TO_INJECT" ]; then
        echo "Error: Unable to download the code sample to inject from the repository (HTTP $HTTP_RESPONSE)"
        exit 1
    fi

    # Check if the preload file is already patched (not the first install)
    if ! grep -q 'document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})' "$(normalizePath "$VENCORD_PRELOAD_FILE")"; then
        echo "The preload file is already patched, skipping the patching process..."
    else
        # Make backup of the preload file
        echo "Making a backup of the preload file..."
        cp "$(normalizePath "$VENCORD_PRELOAD_FILE")" "$(normalizePath "$VENCORD_PRELOAD_FILE").bak"
        
        echo "Injecting the code from the repository into the preload file..."
        # Check if the markers exist in the preload file
        if grep -q 'document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})' "$(normalizePath "$VENCORD_PRELOAD_FILE")"; then
            # Inject the code sample between the specified markers into the preload file
            sed -i "s|document\.addEventListener(\"DOMContentLoaded\",()=>document\.documentElement\.appendChild(r),{once:!0})|document.addEventListener(\"DOMContentLoaded\",()=>{document.documentElement.appendChild(r);${CODE_TO_INJECT}},{once:!0})|" "$(normalizePath "$VENCORD_PRELOAD_FILE")"
            if [ $? -eq 0 ]; then
                echo "The preload file was patched successfully."
            else
                echo "Error: Failed to patch the preload file."
                exit 1
            fi
        else
            echo "Error: Markers not found in the preload file. Cannot patch the file."
            exit 1
        fi
    fi
fi

# Check if the Vencord VCC folder exists, if not, create it
if [ ! -d "$(normalizePath "$VENCORD_PATH_VCC")" ]; then
    echo 'Creating the VCC folder "'${VENCORD_PATH_VCC}'" in Vencord...'
    mkdir "$(normalizePath "$VENCORD_PATH_VCC")"
fi

# Put the custom code file in the Vencord VCC folder
echo 'Downloading the custom code file from the repository to "'${VENCORD_VCC_CUSTOM_CODE_FILE}'"...'
download_file "$VCC_REPOSITORY_VCC_CUSTOM_CODE_FILE" "$(normalizePath "$VENCORD_VCC_CUSTOM_CODE_FILE")"
echo 'The custom code file was downloaded successfully'

# Check if the VCC folder exists, if not, create it
if [ ! -d "$(normalizePath "$VCC_PATH")" ]; then
    echo 'Creating the VCC folder "'${VCC_PATH}'"...'
    mkdir "$(normalizePath "$VCC_PATH")"
fi

# Put the mute script in the VCC folder
echo 'Downloading the mute script from the repository to "'${VCC_MUTE_PATH}'"...'
download_file "$VCC_REPOSITORY_VCC_MUTE_PATH" "$(normalizePath "$VCC_MUTE_PATH")"
echo 'The mute script was downloaded successfully'
chmod +x "$(normalizePath "$VCC_MUTE_PATH")"
echo 'The mute script was made executable (chmod +x)'

# Put the deafen script in the VCC folder
echo 'Downloading the deafen script from the repository to "'${VCC_DEAFEN_PATH}'"...'
download_file "$VCC_REPOSITORY_VCC_DEAFEN_PATH" "$(normalizePath "$VCC_DEAFEN_PATH")"
echo 'The deafen script was downloaded successfully'
chmod +x "$(normalizePath "$VCC_DEAFEN_PATH")"
echo 'The deafen script was made executable (chmod +x)'

# Ensure a config file exists in the VCC folder without overwriting user settings
if [ -f "$(normalizePath "$VCC_CONFIG_PATH")" ]; then
    echo 'A config file already exists at "'${VCC_CONFIG_PATH}'". Preserving existing settings.'
else
    echo 'Downloading the default config file from the repository to "'${VCC_CONFIG_PATH}'"...'
    download_file "$VCC_REPOSITORY_VCC_CONFIG_PATH" "$(normalizePath "$VCC_CONFIG_PATH")"
    echo 'The default config file was downloaded successfully'
fi

# Ensure the VCC config file contains the right Vencord path
if grep -q '^vencord_path=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    if ! grep -q "^vencord_path=\"$(normalizePath "$VENCORD_PATH")\"$" "$(normalizePath "$VCC_CONFIG_PATH")"; then
        echo 'Updating the VCC config file with the selected Vencord path...'
        sed -i -e "s|^vencord_path=.*|vencord_path=\"$(normalizePath "$VENCORD_PATH")\"|" "$(normalizePath "$VCC_CONFIG_PATH")"
        echo 'The VCC config file was updated successfully'
    fi
else
    echo 'Adding Vencord path to the VCC config file...'
    echo "vencord_path=\"$(normalizePath "$VENCORD_PATH")\"" >> "$(normalizePath "$VCC_CONFIG_PATH")"
    echo 'The Vencord path was added to the VCC config file'
fi



# End of the installation
# --- Auto-repatch options and setup ---

# Ensure auto_repatch and auto_restart keys exist with defaults
if ! grep -q '^auto_repatch=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    echo 'auto_repatch="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^auto_restart=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    echo 'auto_restart="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^autorepatch_interval=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    echo 'autorepatch_interval="30s"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^auto_update=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    echo 'auto_update="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^auto_update_interval=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    echo 'auto_update_interval="15m"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi

read -p 'Do you want to enable automatic repatch (checks and re-applies if needed)? (y/n) ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sed -i -e 's|^auto_repatch=.*|auto_repatch="true"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    echo "Choose auto-repatch check interval:"
    echo "  1) 30 seconds (recommended)"
    echo "  2) 1 minute"
    echo "  3) 3 minutes"
    read -p 'Enter choice [1-3]: ' interval_choice
    case "$interval_choice" in
        2) sed -i -e 's|^autorepatch_interval=.*|autorepatch_interval="1m"|' "$(normalizePath "$VCC_CONFIG_PATH")" ;;
        3) sed -i -e 's|^autorepatch_interval=.*|autorepatch_interval="3m"|' "$(normalizePath "$VCC_CONFIG_PATH")" ;;
        *) sed -i -e 's|^autorepatch_interval=.*|autorepatch_interval="30s"|' "$(normalizePath "$VCC_CONFIG_PATH")" ;;
    esac
    read -p 'Do you also want to enable auto-restart of Vesktop after repatch? (y/n) ' -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i -e 's|^auto_restart=.*|auto_restart="true"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    else
        sed -i -e 's|^auto_restart=.*|auto_restart="false"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    fi
fi

# Ask for auto-update
read -p 'Do you want to enable automatic update (periodically fetch latest VCC files)? (y/n) ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sed -i -e 's|^auto_update=.*|auto_update="true"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    # Keep default interval 6h; advanced users can edit .config
else
    sed -i -e 's|^auto_update=.*|auto_update="false"|' "$(normalizePath "$VCC_CONFIG_PATH")"
fi

# Create auto-repatch scripts in ~/.vesktopCustomCommands
cat > "$(normalizePath "$VCC_PATH")vcc-autorepatch.sh" <<'EOSH'
#!/bin/bash

# Lock to avoid concurrent runs
LOCK_FILE="$HOME/.vesktopCustomCommands/.autorepatch.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

CONFIG="$HOME/.vesktopCustomCommands/.config"

normalizePath() {
  local input_path="$1"
  if [[ "$input_path" == ~* ]]; then
    echo "${input_path/#\~/$HOME}"
  else
    echo "$input_path"
  fi
}

detect_vesktop() {
  DETECTED=""; START_CMD=""; KILL_CMD=""
  if command -v flatpak >/dev/null 2>&1; then
    if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
      DETECTED="flatpak"
      FP_BIN="$(command -v flatpak)"; ARCH="$(uname -m)"
      START_CMD="$FP_BIN run --branch=stable --arch=$ARCH --command=startvesktop --file-forwarding dev.vencord.Vesktop @@u %U @@"
      KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
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

ensure_terminal() {
  for t in konsole gnome-terminal xfce4-terminal kitty alacritty wezterm tilix mate-terminal lxterminal xterm; do
    if command -v "$t" >/dev/null 2>&1; then
      echo "$t"; return 0
    fi
  done
  echo "xterm" # fallback
}

is_patched() {
  local preload_file="$1"
  grep -q 'document.addEventListener("DOMContentLoaded",()=>\{document.documentElement.appendChild(r);' "$preload_file"
}

patch_preload() {
  local preload_file="$1"
  local sample_url="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main/src/vencord/vencordDesktopPreload_sample.js"
  CODE_TO_INJECT=$(curl -s -w "%{http_code}" "$sample_url") || return 1
  HTTP_RESPONSE="${CODE_TO_INJECT: -3}"; CODE_TO_INJECT="${CODE_TO_INJECT%???}"
  if [ "$HTTP_RESPONSE" -ne 200 ] || [ -z "$CODE_TO_INJECT" ]; then
    echo "Error: Unable to download code sample (HTTP $HTTP_RESPONSE)" >&2
    return 1
  fi
  if grep -q 'document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})' "$preload_file"; then
    sed -i "s|document\.addEventListener(\"DOMContentLoaded\",()=>document\.documentElement\.appendChild(r),{once:!0})|document.addEventListener(\"DOMContentLoaded\",()=>{document.documentElement.appendChild(r);${CODE_TO_INJECT}},{once:!0})|" "$preload_file"
    return $?
  fi
  return 0
}

restart_vesktop() {
  detect_vesktop
  if [ -n "$DETECTED" ]; then
    eval "$KILL_CMD"
    sleep 1
    nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
    return 0
  fi
  return 1
}

main() {
  [ -f "$CONFIG" ] || exit 0
  # shellcheck disable=SC1090
  source "$CONFIG"
  [ "${auto_repatch}" = "true" ] || exit 0
  # Also use this timer for auto_update checks even if auto_repatch is off
  AUTO_UPDATE_ACTIVE=false
  if [ "${auto_update}" = "true" ]; then
    AUTO_UPDATE_ACTIVE=true
  fi
  if [ "${auto_repatch}" != "true" ] && [ "$AUTO_UPDATE_ACTIVE" != true ]; then
    exit 0
  fi
  PRELOAD_FILE="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")/vencordDesktopPreload.js"
  if [ ! -f "$PRELOAD_FILE" ]; then
    # If no preload yet but auto_update is on, still run update checks
    PRELOAD_FILE=""
  fi
  # Auto-update check
  if [ "$AUTO_UPDATE_ACTIVE" = true ]; then
    bash -lc "$HOME/.vesktopCustomCommands/vcc-autoupdate.sh" || true
  fi
  # Auto-repatch check
  if [ -n "$PRELOAD_FILE" ] && [ -f "$PRELOAD_FILE" ]; then
    if is_patched "$PRELOAD_FILE"; then
      exit 0
    fi
    if [ "${auto_repatch}" = "true" ]; then
      if [ "${auto_restart}" = "true" ]; then
        if patch_preload "$PRELOAD_FILE"; then
          restart_vesktop || true
        fi
      else
        term=$(ensure_terminal)
        nohup "$term" -e bash -lc "$HOME/.vesktopCustomCommands/vcc-repatch-interactive.sh" >/dev/null 2>&1 & disown
      fi
    fi
  fi
}

main "$@"
EOSH
chmod +x "$(normalizePath "$VCC_PATH")vcc-autorepatch.sh"

cat > "$(normalizePath "$VCC_PATH")vcc-repatch-interactive.sh" <<'EOSH'
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

detect_vesktop() {
  DETECTED=""; START_CMD=""; KILL_CMD=""
  if command -v flatpak >/dev/null 2>&1; then
    if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
      DETECTED="flatpak"
      FP_BIN="$(command -v flatpak)"; ARCH="$(uname -m)"
      START_CMD="$FP_BIN run --branch=stable --arch=$ARCH --command=startvesktop --file-forwarding dev.vencord.Vesktop @@u %U @@"
      KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
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

is_patched() {
  local preload_file="$1"
  grep -q 'document.addEventListener("DOMContentLoaded",()=>\{document.documentElement.appendChild(r);' "$preload_file"
}

patch_preload() {
  local preload_file="$1"
  local sample_url="https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main/src/vencord/vencordDesktopPreload_sample.js"
  CODE_TO_INJECT=$(curl -s -w "%{http_code}" "$sample_url") || return 1
  HTTP_RESPONSE="${CODE_TO_INJECT: -3}"; CODE_TO_INJECT="${CODE_TO_INJECT%???}"
  if [ "$HTTP_RESPONSE" -ne 200 ] || [ -z "$CODE_TO_INJECT" ]; then
    echo "Error: Unable to download code sample (HTTP $HTTP_RESPONSE)" >&2
    return 1
  fi
  if grep -q 'document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})' "$preload_file"; then
    sed -i "s|document\.addEventListener(\"DOMContentLoaded\",()=>document\.documentElement\.appendChild(r),{once:!0})|document.addEventListener(\"DOMContentLoaded\",()=>{document.documentElement.appendChild(r);${CODE_TO_INJECT}},{once:!0})|" "$preload_file"
    return $?
  fi
  return 0
}

restart_vesktop() {
  detect_vesktop
  if [ -n "$DETECTED" ]; then
    eval "$KILL_CMD"; sleep 1
    nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
    return 0
  fi
  return 1
}

[ -f "$CONFIG" ] || { echo "Missing config at $CONFIG"; exit 1; }
# shellcheck disable=SC1090
source "$CONFIG"
PRELOAD_FILE="$(normalizePath "${vencord_path:-~/.config/Vencord/dist/}")/vencordDesktopPreload.js"

echo "vesktopCustomCommands: le repatch est nécessaire."
read -p "Voulez-vous repatch maintenant ? (y/n) " -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if patch_preload "$PRELOAD_FILE"; then
    echo "Repatch effectué."
    read -p "Voulez-vous relancer Vesktop maintenant ? (y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      restart_vesktop || echo "Impossible de relancer automatiquement Vesktop."
    fi
    exit 0
  else
    echo "Le repatch a échoué."
    exit 1
  fi
else
  echo "Désactivation de l'auto-repatch proposée."
  read -p "Confirmez-vous la désactivation de l'auto-repatch ? (y/n) " -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sed -i -e 's|^auto_repatch=.*|auto_repatch="false"|' "$CONFIG"
    echo "Auto-repatch désactivé."
    exit 0
  else
    echo "Annulé. Aucune modification des paramètres."
    exit 0
  fi
fi
EOSH
chmod +x "$(normalizePath "$VCC_PATH")vcc-repatch-interactive.sh"

# Create systemd user service and timer
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"
cat > "$SYSTEMD_USER_DIR/vcc-autorepatch.service" <<'EOUNIT'
[Unit]
Description=vesktopCustomCommands auto-repatch service

[Service]
Type=oneshot
ExecStart=/bin/bash -lc "$HOME/.vesktopCustomCommands/vcc-autorepatch.sh"
EOUNIT

AUTOREPATCH_INTERVAL=$(grep '^autorepatch_interval=' "$(normalizePath "$VCC_CONFIG_PATH")" | sed -E 's/^autorepatch_interval=\"(.*)\"/\1/')
AUTOUPDATE_INTERVAL=$(grep '^auto_update_interval=' "$(normalizePath "$VCC_CONFIG_PATH")" | sed -E 's/^auto_update_interval=\"(.*)\"/\1/')

# Decide timer interval: if auto-repatch is enabled use its interval, else if only auto-update is enabled use its interval
TIMER_INTERVAL="$AUTOREPATCH_INTERVAL"
if command -v bash >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source "$(normalizePath "$VCC_CONFIG_PATH")"
    if [ "${auto_repatch}" != "true" ] && [ "${auto_update}" = "true" ]; then
        TIMER_INTERVAL="$AUTOUPDATE_INTERVAL"
    fi
fi

cat > "$SYSTEMD_USER_DIR/vcc-autorepatch.timer" <<EOUNIT
[Unit]
Description=Run VCC auto-repatch periodically

[Timer]
OnBootSec=30s
OnUnitActiveSec=${TIMER_INTERVAL}
Persistent=true

[Install]
WantedBy=timers.target
EOUNIT

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload || true
    # shellcheck disable=SC1090
    source "$(normalizePath "$VCC_CONFIG_PATH")"
    if [ "${auto_repatch}" = "true" ] || [ "${auto_update}" = "true" ]; then
        systemctl --user enable --now vcc-autorepatch.timer || true
    else
        systemctl --user disable --now vcc-autorepatch.timer 2>/dev/null || true
    fi
fi

echo 'DONE: The installation was successful!'
offer_restart_vesktop

exit 0