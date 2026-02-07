#!/bin/bash
scriptVersion="1.1.0"

pidStoreFile="/tmp/streamity.conf"
logFolder="/var/log/streamity"

obsProfile1="Full Private Stream"
obsCollection1="Full Private"

obsProfile2="Partial Public Stream"
obsCollection2="Partial Public"

obsCounter=0

#echo "Running as: $(whoami)"


# Shows Streamity program information
progInfo() {
    echo "Streamity v$scriptVersion. Developed by S.I. Dalton."
    echo "Licensed under the BSL-1.0 license."
    echo "For more information, visit https://github.com/sidalton/streamity"
}

# Function to simulate a service for debugging
debugService() {
    while true; do
    echo "[$(date)] Debug log for $1."
    sleep 2
    done &
}

# Function to start the video capture service
videoService() {
     exec 3> >(dvgrab - | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2 > "$logFolder/video.log" 2>&1 &)
     #debugService "video" >> $logFolder/video.log
     videoPID=$!
     echo "$videoPID" >> $pidStoreFile
     sleep 5
}

# Function to start an OBS instance with specified profile and collection
obsService() {
    ((obsCounter++))
    flatpak run com.obsProject.Studio --multi --profile "$1" --collection "$2" > "$logFolder/obs$2.log" 2>&1 &
    #debugService "obs$1$2" >> "$logFolder/obs$obsCounter.log"
    declare obsPID="obs${obsCounter}PID"=$!
    echo "$obsPID" >> $pidStoreFile
    sleep 5
}


# Function to start the streaming flow
startFlow() {
    progInfo
    
    # check for variables to see if already running (later version)
    true > $pidStoreFile
    printf "Press [Enter] to start..."
    read -r _ || true

    videoService &

    obsService "$obsProfile1" "$obsCollection1" &

    obsService "$obsProfile2" "$obsCollection2" &

    echo "Streamity is now running. Please wait a few moments for services to open."
    exit 0
}

# Function to stop the streaming flow
stopFlow() {
    # check if variable exists
    cat $pidStoreFile
    grep -E '^[0-9]+$' $pidStoreFile | xargs kill
    true > "$pidStoreFile"

    echo "Streamity has stopped."
    exit 0
}

helpMessage() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  --start, -s       Start the streaming processes"
    echo "  --stop, -x        Stop the streaming processes"
    echo "  --logs, -l        Display the log file locations"
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
    --help|-h)
        helpMessage
    ;;
    --logs|-l)
        echo "Logs may be found at the path: $logFolder."
        ;;
    *)
        echo "Invalid option. Use --help or -h for usage information."
        exit 1
    ;;
esac