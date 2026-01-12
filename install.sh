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
    RUNNING="false"

    # Prefer explicit flatpak if present
    if command -v flatpak >/dev/null 2>&1; then
        if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
            DETECTED="flatpak"
            FP_BIN="$(command -v flatpak)"
            ARCH="$(uname -m)"
            START_CMD="$FP_BIN run dev.vencord.Vesktop"
            KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
            if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then RUNNING="true"; fi
            return
        fi
    fi

    # System package (vesktop in PATH)
    if command -v vesktop >/dev/null 2>&1; then
        DETECTED="system"
        START_CMD="vesktop"
        KILL_CMD="pkill -x vesktop || pkill -f vesktop || true"
        if pgrep -x vesktop >/dev/null 2>&1 || pgrep -f '[Vv]esktop' >/dev/null 2>&1; then RUNNING="true"; fi
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
            RUNNING="true"
            return
        fi
    fi
}

offer_restart_vesktop() {
    detect_vesktop
    if [ -n "$DETECTED" ]; then
        echo "We detected Vesktop variant: $DETECTED"
        if [ "$RUNNING" = "true" ]; then
            read -p 'Vesktop is running. Do you want us to restart it now? (y/n) ' -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                eval "$KILL_CMD"
                sleep 1
            nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
                echo 'Vesktop was restarted successfully.'
                return
            else
                echo 'You can restart Vesktop manually to apply the changes.'
                return
            fi
        else
            read -p 'Vesktop is not running. Do you want us to start it now? (y/n) ' -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
                echo 'Vesktop was started successfully.'
                return
            else
                echo 'You can start Vesktop to apply and see the changes.'
                return
            fi
        fi
    fi
    echo '⚠️ Please (re)start Vesktop to apply the changes'
}

# Ask to the user if he accepts the automatic installation
read -p 'Do you want to automatically install "vesktopCustomCommands"? (y/n) ' -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "For a manual installation, please refer to the README.md file in the repository or follow the next steps:"
    echo "1. Download the 'dist' folder from the repository or its content."
    echo "2. 'dist' is separated in two parts:"
    echo "    - 'vencord' folder contains the files to inject in the Vencord main file."
    echo "    - 'vesktopCustomCommands' folder contains the scripts to mute/deafen and the '.config' file."
    echo "3. You can make a backup of your Vencord main file (usually located in '~/.config/Vencord/dist/vencordDesktopMain.js' so 'cp ~/.config/Vencord/dist/vencordDesktopMain.js ~/.config/Vencord/dist/vencordDesktopMain.js.bak') or not, if you want to restore it later you can delete the file and start Vesktop to recreate it."
    echo "4. Inject the content of 'vencordDesktopMain_sample.js' in your Vencord main file (usually located in '~/.config/Vencord/dist/vencordDesktopMain.js'):"
    echo "    - UNIVERSAL METHOD (works with all Vencord versions): Insert the content of 'vencordDesktopMain_sample.js' just before the line '//# sourceURL='"
    echo "    (*NOT RECOMMENDED to replace the whole file, as it may become obsolete with Vesktop updates*)"
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
VENCORD_MAIN_FILE="${VENCORD_PATH}vencordDesktopMain.js"
VENCORD_VCC_CUSTOM_CODE_FILE="${VENCORD_PATH_VCC}customCode.js"

VCC_PATH="$HOME/.vesktopCustomCommands/"
VCC_MUTE_PATH="${VCC_PATH}mute.sh"
VCC_DEAFEN_PATH="${VCC_PATH}deafen.sh"
VCC_CONFIG_PATH="${VCC_PATH}.config"

# SOURCE PATHS
REPOSITORY_SOURCE="https://raw.githubusercontent.com/"
VCC_REPOSITORY_USER="NitramO-YT"
VCC_REPOSITORY_NAME="vesktopCustomCommands"
VCC_REPOSITORY_REFS="refs/heads"
VCC_REPOSITORY_BRANCH="main"
VCC_REPOSITORY_BASE_REFS="${REPOSITORY_SOURCE}${VCC_REPOSITORY_USER}/${VCC_REPOSITORY_NAME}/${VCC_REPOSITORY_REFS}/${VCC_REPOSITORY_BRANCH}/"
VCC_REPOSITORY_BASE="${REPOSITORY_SOURCE}${VCC_REPOSITORY_USER}/${VCC_REPOSITORY_NAME}/${VCC_REPOSITORY_BRANCH}/"
VCC_REPOSITORY_DIST="${VCC_REPOSITORY_BASE}dist/"

VCC_REPOSITORY_VENCORD_PATH="${VCC_REPOSITORY_DIST}vencord/"
# Main injection sample file is stored under dist in the repository
VCC_REPOSITORY_VENCORD_MAIN_FILE_SAMPLE="${VCC_REPOSITORY_VENCORD_PATH}vencordDesktopMain_sample.js"
VCC_REPOSITORY_VCC_CUSTOM_CODE_FILE="${VCC_REPOSITORY_VENCORD_PATH}customCode.js"

VCC_REPOSITORY_VCC_PATH="${VCC_REPOSITORY_DIST}vesktopCustomCommands/"
VCC_REPOSITORY_VCC_MUTE_PATH="${VCC_REPOSITORY_VCC_PATH}mute.sh"
VCC_REPOSITORY_VCC_DEAFEN_PATH="${VCC_REPOSITORY_VCC_PATH}deafen.sh"
VCC_REPOSITORY_VCC_CONFIG_PATH="${VCC_REPOSITORY_VCC_PATH}.config"



# Check if the Vencord main file exists and try to patch it
MAIN_FILE_PATCHED=false
if [ ! -f "$(normalizePath "$VENCORD_MAIN_FILE")" ]; then
    read -p 'The main file of Vencord of Vesktop does not exist, do you want to try to make it automatically? (y/n) ' -n 1 -r
    echo    # move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting Vesktop..."
        detect_vesktop
        if [ -n "$START_CMD" ]; then
            nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
        else
            vesktop &
        fi
        sleep 5
        echo "Closing Vesktop..."
        detect_vesktop
        if [ -n "$KILL_CMD" ]; then
            eval "$KILL_CMD"
        else
            killall vesktop 2>/dev/null || true
        fi
        if [ ! -f "$(normalizePath "$VENCORD_MAIN_FILE")" ]; then
            echo "Error: Vesktop was not able to create the main file."
            echo "Please start Vesktop manually and wait for the files to be created, then run the script again."
            exit 1
        fi
    else
        echo "Please start Vesktop and wait for the main file to be created, and then run the script again"
        exit 0
    fi
fi

# Patch the Vencord main file if it was not patched before
if [ "$MAIN_FILE_PATCHED" = false ]; then
    echo "Trying to patch the Vencord main file..."
    echo "Downloading the code sample to inject from the repository..."

    # Download the code sample to inject from the repository
    CODE_TO_INJECT=$(curl -s -w "%{http_code}" "$VCC_REPOSITORY_VENCORD_MAIN_FILE_SAMPLE")
    HTTP_RESPONSE="${CODE_TO_INJECT: -3}"
    CODE_TO_INJECT="${CODE_TO_INJECT%???}"

    if [ "$HTTP_RESPONSE" -ne 200 ] || [ -z "$CODE_TO_INJECT" ]; then
        echo "Error: Unable to download the code sample to inject from the repository (HTTP $HTTP_RESPONSE)"
        exit 1
    fi

    # Check if the main file is already patched (not the first install)
    # Universal detection: check for our VCC signature in the injection code
    ALREADY_PATCHED=false
    if grep -q '\[VesktopCustomCommands\]' "$(normalizePath "$VENCORD_MAIN_FILE")"; then
        ALREADY_PATCHED=true
    fi

    if [ "$ALREADY_PATCHED" = true ]; then
        echo "The main file is already patched, skipping the patching process..."
    else
        # Make backup of the main file
        echo "Making a backup of the main file..."
        cp "$(normalizePath "$VENCORD_MAIN_FILE")" "$(normalizePath "$VENCORD_MAIN_FILE").bak"

        echo "Injecting the code from the repository into the main file..."
        # Universal injection: inject before the source map (works with all Vencord versions)
        if grep -q '//# sourceURL=' "$(normalizePath "$VENCORD_MAIN_FILE")"; then
            echo "Using universal injection method (works with all Vencord versions)..."
            sed -i "s|//# sourceURL=|${CODE_TO_INJECT}//# sourceURL=|" "$(normalizePath "$VENCORD_MAIN_FILE")"
            if [ $? -eq 0 ]; then
                echo "The main file was patched successfully."
            else
                echo "Error: Failed to patch the main file."
                exit 1
            fi
        else
            echo "Error: Source map marker not found in the main file. Cannot patch the file."
            echo "This may indicate an incompatible Vencord version."
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
    # Ensure config ends with a newline to avoid concatenation on appends
    sed -i -e '$a\' "$(normalizePath "$VCC_CONFIG_PATH")"
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
    printf '\n%s\n' "vencord_path=\"$(normalizePath "$VENCORD_PATH")\"" >> "$(normalizePath "$VCC_CONFIG_PATH")"
    echo 'The Vencord path was added to the VCC config file'
fi



# End of the installation
# --- Auto-repatch options and setup ---

# Ensure auto_repatch and auto_restart keys exist with defaults
# Fix potential previous bad concat: insert newline before auto_* if stuck to vencord_path line
sed -i -E 's|(vencord_path=\"[^\"]*\")auto_|\1\nauto_|' "$(normalizePath "$VCC_CONFIG_PATH")"

if ! grep -q '^auto_repatch=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    printf '\n%s\n' 'auto_repatch="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^auto_restart=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    printf '\n%s\n' 'auto_restart="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^autorepatch_interval=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    printf '\n%s\n' 'autorepatch_interval="30s"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^auto_update=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    printf '\n%s\n' 'auto_update="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi
if ! grep -q '^auto_update_interval=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
    printf '\n%s\n' 'auto_update_interval="15m"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
fi

read -p 'Do you want to enable automatic repatch (checks and re-applies if needed)? (y/n) ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Ensure newline end, then set auto_repatch=true
    sed -i -e '$a\' "$(normalizePath "$VCC_CONFIG_PATH")"
    if grep -q '^auto_repatch=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
        sed -i -e 's|^auto_repatch=.*|auto_repatch="true"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    else
        printf '\n%s\n' 'auto_repatch="true"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
    fi
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
        if grep -q '^auto_restart=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
            sed -i -e 's|^auto_restart=.*|auto_restart="true"|' "$(normalizePath "$VCC_CONFIG_PATH")"
        else
            printf '\n%s\n' 'auto_restart="true"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
        fi
    else
        if grep -q '^auto_restart=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
            sed -i -e 's|^auto_restart=.*|auto_restart="false"|' "$(normalizePath "$VCC_CONFIG_PATH")"
        else
            printf '\n%s\n' 'auto_restart="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
        fi
    fi
fi

# Ask for auto-update
read -p 'Do you want to enable automatic update (periodically fetch latest VCC files)? (y/n) ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if grep -q '^auto_update=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
        sed -i -e 's|^auto_update=.*|auto_update="true"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    else
        printf '\n%s\n' 'auto_update="true"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
    fi
    # Keep default interval 6h; advanced users can edit .config
else
    if grep -q '^auto_update=' "$(normalizePath "$VCC_CONFIG_PATH")"; then
        sed -i -e 's|^auto_update=.*|auto_update="false"|' "$(normalizePath "$VCC_CONFIG_PATH")"
    else
        printf '\n%s\n' 'auto_update="false"' >> "$(normalizePath "$VCC_CONFIG_PATH")"
    fi
fi

# Create auto-repatch scripts in ~/.vesktopCustomCommands
echo 'Downloading auto-repatch script to "'${VCC_PATH}'vcc-autorepatch.sh"...'
download_file "${VCC_REPOSITORY_VCC_AUTOREPATCH_PATH:-${VCC_REPOSITORY_VCC_PATH}vcc-autorepatch.sh}" "$(normalizePath "${VCC_PATH}vcc-autorepatch.sh")"
chmod +x "$(normalizePath "${VCC_PATH}vcc-autorepatch.sh")"

echo 'Downloading interactive repatch helper to "'${VCC_PATH}'vcc-repatch-interactive.sh"...'
download_file "${VCC_REPOSITORY_VCC_REPATCH_INTERACTIVE_PATH:-${VCC_REPOSITORY_VCC_PATH}vcc-repatch-interactive.sh}" "$(normalizePath "${VCC_PATH}vcc-repatch-interactive.sh")"
chmod +x "$(normalizePath "${VCC_PATH}vcc-repatch-interactive.sh")"

# Download auto-update script in ~/.vesktopCustomCommands
echo 'Downloading auto-update script to "'${VCC_PATH}'vcc-autoupdate.sh"...'
download_file "${VCC_REPOSITORY_VCC_PATH}vcc-autoupdate.sh" "$(normalizePath "${VCC_PATH}vcc-autoupdate.sh")"
chmod +x "$(normalizePath "$VCC_PATH")vcc-autoupdate.sh"

# Persist session environment for GUI prompts under systemd user
ENV_FILE="$(normalizePath "$VCC_PATH")/.env"
{
  [ -n "$DISPLAY" ] && echo "DISPLAY=$DISPLAY"
  [ -n "$WAYLAND_DISPLAY" ] && echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
  [ -n "$XDG_RUNTIME_DIR" ] && echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
  [ -n "$DBUS_SESSION_BUS_ADDRESS" ] && echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
} > "$ENV_FILE"

# Create systemd user service and timer
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"
cat > "$SYSTEMD_USER_DIR/vcc-autorepatch.service" <<'EOUNIT'
[Unit]
Description=vesktopCustomCommands auto-repatch service

[Service]
Type=oneshot
ExecStart=%h/.vesktopCustomCommands/vcc-autorepatch.sh
EnvironmentFile=-%h/.vesktopCustomCommands/.env
# Ensure spawned terminals survive after the service exits
KillMode=process
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
        # Lancer un premier run immédiat pour vérifier l'état sans attendre le timer
        systemctl --user start vcc-autorepatch.service 2>/dev/null || true
    else
        systemctl --user disable --now vcc-autorepatch.timer 2>/dev/null || true
    fi
fi

echo 'DONE: The installation was successful!'
offer_restart_vesktop

exit 0