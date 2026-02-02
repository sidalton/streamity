#!/bin/sh
scriptVersion="0.1"
remoteScript=$(curl -s "https://raw.githubusercontent.com/sidalton/streamity/refs/heads/main/streamity.sh")

# Shows Streamity program information
progInfo() {
    echo "Streamity $scriptVersion. Developed by S.I. Dalton."
    echo "Licensed under the BSL-1.0 license."
    echo "For more information, visit https://github.com/sidalton/streamity"
}

progInfo

# Function to start the streaming flow
startFlow() {
    printf "Press [Enter] to start..."
    read -r _ || true
    dvgrab - | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2 > /dev/null 2>&1 &
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
    remoteVersion=$(printf '%s\n' "$remoteScript" | grep 'scriptVersion=' | head -n1 | cut -d'"' -f2)
    if [ "$remoteVersion" != "$scriptVersion" ]; then
        echo "A new version of Streamity is available: $remoteVersion. $scriptVersion currently running."
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
        printf '%s\n' "$remoteScript" > "$0"
        chmod +x "$0"
        exec "$0" "$@"
    fi
}

# Main script logic
case $1 in
    --start|-s)
        startFlow
    ;;
    --stop|-h)
        stopFlow
    ;;
    --update|-u)
        updateCheck "$@"
    ;;
esac