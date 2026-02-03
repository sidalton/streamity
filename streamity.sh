#!/bin/sh
scriptVersion="0.1.3"
set -o pipefail

# Variables for temp files for logs
videoTmpFile=$(mktemp)
obs1TmpFile=$(mktemp)
obs2TmpFile=$(mktemp)

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
    exec 3> >(dvgrab - | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2 > "$videoTmpFile" 2>&1 &)
    videoPID=$!
    sleep 3
    flatpak run com.obsproject.Studio --multi --profile "Partial Public Stream" > "$obs1TmpFile" 2>&1 &
    obs1PID=$!
    sleep 5
    flatpak run com.obsproject.Studio --multi --profile "Full Private Stream" > "$obs2TmpFile" 2>&1 &
    obs2PID=$!
}

# Function to stop the streaming flow
stopFlow() {
    kill $videoPID
    wait $videoPID

    kill $obs1PID
    wait $obs1PID

    kill $obs2PID
    wait $obs2PID

    echo "Streamity has stopped."
    exit 0
}

helpMessage() {
    echo "Usage: $0 [OPTION] [LOGGING]"
    echo "Options:"
    echo "  --start, -s       Start the streaming flow"
    echo "  --stop, -x        Stop the streaming flow"
    echo "  --help, -h        Display this help message"
    echo "Logging Options:"
    echo "  --log, -l         Enable logging (saves to /var/log/streamity)"
}

saveLogs() {
    videoLogs=$(cat "$videoTmpFile")
    obs1Logs=$(cat "$obs1TmpFile")
    obs2Logs=$(cat "$obs2TmpFile")

    echo "$videoLogs" > /var/log/streamity/video.log
    echo "$obs1Logs" > /var/log/streamity/obs1.log
    echo "$obs2Logs" > /var/log/streamity/obs2.log
    )
}

# Main script logic
case $1 in
    --start|-s)
        startFlow
    ;;
    --stop|-x)
        stopFlow
    ;;
    --help|-h)
        helpMessage
    ;;
esac

# Secondary options handling
case $2 in
    --log|-l)
        saveLogs
    ;;
esac