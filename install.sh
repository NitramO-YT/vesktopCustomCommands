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
    echo "4. Either inject the content of 'vencordDesktopPreload_sample.js' between the line 'document.addEventListener(\"DOMContentLoaded\",()=>{' and 'document.documentElement.appendChild(r)},{once:!0})' in your Vencord preload file (usually located in '~/.config/Vencord/dist/vencordDesktopPreload.js') or replace it with the content of 'vencordDesktopPreload.js' (*NOT RECOMMENDED, as in the event of a Vesktop update, if VCC has not been updated since then, it is less reliable, and this file may be obsolete*.)."
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
    if ! grep -q 'document.addEventListener("DOMContentLoaded",()=>{document.documentElement.appendChild(r)},{once:!0})' "$(normalizePath "$VENCORD_PRELOAD_FILE")"; then
        echo "The preload file is already patched, skipping the patching process..."
    else
        # Make backup of the preload file
        echo "Making a backup of the preload file..."
        cp "$(normalizePath "$VENCORD_PRELOAD_FILE")" "$(normalizePath "$VENCORD_PRELOAD_FILE").bak"
        
        echo "Injecting the code from the repository into the preload file..."
        # Check if the markers exist in the preload file
        if grep -q 'document.addEventListener("DOMContentLoaded",()=>{document.documentElement.appendChild(r)},{once:!0})' "$(normalizePath "$VENCORD_PRELOAD_FILE")"; then
            # Inject the code sample between the specified markers into the preload file
            sed -i "s|document.addEventListener(\"DOMContentLoaded\",()=>{document.documentElement.appendChild(r)|document.addEventListener(\"DOMContentLoaded\",()=>{document.documentElement.appendChild(r);${CODE_TO_INJECT}|" "$(normalizePath "$VENCORD_PRELOAD_FILE")"
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

# Put the config file in the VCC folder
echo 'Downloading the config file from the repository to "'${VCC_CONFIG_PATH}'"...'
download_file "$VCC_REPOSITORY_VCC_CONFIG_PATH" "$(normalizePath "$VCC_CONFIG_PATH")"
echo 'The config file was downloaded successfully'

# Check if the VCC config file contains the right Vencord path, if not, update it
if ! grep -q "vencord_path=\"$(normalizePath "$VENCORD_PATH")\"" "$VCC_CONFIG_PATH"; then
    echo 'Updating the VCC config file with the right Vencord path...'
    sed -i -e "s|vencord_path=.*|vencord_path=\"$(normalizePath "$VENCORD_PATH")\"|" "$(normalizePath "$VCC_CONFIG_PATH")"
    echo 'The VCC config file was updated successfully'
fi



# End of the installation
echo 'DONE: The installation was successful!'
echo '⚠️ Please restart Vesktop to apply the changes'

exit 0