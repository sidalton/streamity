#!/bin/sh
version="0.1-alpha"

progInfo() {
    echo "Streamity $version. Developed by S.I. Dalton."
    echo "Licensed under the BSL-1.0 license."
    echo "For more information, visit https://github.com/sidalton/streamity"
}

# Function to start the streaming flow
startFlow() {
    progInfo
    read "Press [Enter] to start..."
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

# Main script logic
case $1 in
    start)
        startFlow
    ;;
    stop)
        stopFlow
    ;;
    update)
        echo "purr"
    ;;
esac