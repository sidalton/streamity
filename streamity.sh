#!/bin/sh
scriptVersion="0.1.1"
set -o pipefail

# Shows Streamity program information
progInfo() {
    echo "Streamity v$scriptVersion. Developed by S.I. Dalton."
    echo "Licensed under the BSL-1.0 license."
    echo "For more information, visit https://github.com/sidalton/streamity"
}

progInfo

# Function to start the streaming flow
startFlow() {
    printf "Press [Enter] to start..."
    read -r _ || true
    exec 3> >(dvgrab - | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2 > /dev/null 2>&1 &)
    videoPID=$!
    sleep 3
    flatpak run com.obsproject.Studio --multi --profile "Partial Public Stream" > /dev/null 2>&1 &
    sleep 5
    flatpak run com.obsproject.Studio --multi --profile "Full Private Stream" > /dev/null 2>&1 &
}

# Function to stop the streaming flow
stopFlow() {
    pkill ffmpeg
    pkill dvgrab
    flatpak kill com.obsproject.Studio
    echo "All processes have ended."
}

# Function to check the script for updates
checkScriptUpdates() {
    remoteScript=$(curl -s "https://raw.githubusercontent.com/sidalton/streamity/refs/heads/main/streamity.sh")
    remoteVersion=$(printf '%s\n' "$remoteScript" | grep 'scriptVersion=' | head -n1 | cut -d'"' -f2)
    if [ "$remoteVersion" != "$scriptVersion" ]; then
        echo "A new version of Streamity is available: v$remoteVersion. v$scriptVersion currently running."
        return 1
    else
        echo "You are running the latest version of Streamity."
        return 0
    fi
}

# Function to check for updates
updateCheck() {
    echo "Checking for updates..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run this script as root to perform updates."
        exit 1
    fi
    apt-get install --only-upgrade -y ffmpeg dvgrab flatpak
    flatpak update com.obsproject.Studio
    checkScriptUpdates
    if [ $? -eq 1 ]; then
        echo "Updating Streamity script..."
        CHECKSUM_URL="https://raw.githubusercontent.com/sidalton/streamity/refs/heads/main/CHECKSUM"
        SCRIPT_URL="https://raw.githubusercontent.com/sidalton/streamity/refs/heads/main/streamity.sh"

        TMP_SCRIPT=$(mktemp 2>/dev/null || mktemp /tmp/streamity.XXXXXX) || { echo "Failed to create temp file"; exit 1; }
        TMP_CHKSUM=$(mktemp 2>/dev/null || mktemp /tmp/streamity.chk.XXXXXX) || { rm -f "$TMP_SCRIPT"; echo "Failed to create temp checksum file"; exit 1; }

        curl -fsSL -o "$TMP_CHKSUM" "$CHECKSUM_URL" || { echo "Failed to download CHECKSUM"; rm -f "$TMP_SCRIPT" "$TMP_CHKSUM"; exit 1; }
        curl -fsSL -o "$TMP_SCRIPT" "$SCRIPT_URL" || { echo "Failed to download script"; rm -f "$TMP_SCRIPT" "$TMP_CHKSUM"; exit 1; }

        if command -v sha256sum >/dev/null 2>&1; then
            CALC=$(sha256sum "$TMP_SCRIPT" | awk '{print $1}')
        elif command -v shasum >/dev/null 2>&1; then
            CALC=$(shasum -a 256 "$TMP_SCRIPT" | awk '{print $1}')
        else
            echo "No SHA256 utility available to verify checksum."; rm -f "$TMP_SCRIPT" "$TMP_CHKSUM"; exit 1
        fi

        EXPECTED=$(awk '{print $1}' "$TMP_CHKSUM" | head -n1)
        if [ -z "$EXPECTED" ]; then
            echo "Checksum file is empty or invalid."; rm -f "$TMP_SCRIPT" "$TMP_CHKSUM"; exit 1
        fi

        if [ "$CALC" != "$EXPECTED" ]; then
            echo "Checksum mismatch: expected $EXPECTED but got $CALC"; rm -f "$TMP_SCRIPT" "$TMP_CHKSUM"; exit 1
        fi

        mv "$TMP_SCRIPT" "$0" || { echo "Failed to replace script at $0"; rm -f "$TMP_SCRIPT" "$TMP_CHKSUM"; exit 1; }
        rm -f "$TMP_CHKSUM"
        chmod +x "$0"
        exec "$0" "$@"
    fi
    echo "Update process completed."
}

helpMessage() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  --start, -s       Start the streaming flow"
    echo "  --stop, -x        Stop the streaming flow"
    echo "  --update, -u      Check for updates and update the script"
    echo "  --help, -h        Display this help message"
}

# Main script logic
case $1 in
    --start|-s)
        startFlow
    ;;
    --stop|-x)
        stopFlow
    ;;
    --update|-u)
        updateCheck "$@"
    ;;
    --help|-h)
        helpMessage
    ;;
esac