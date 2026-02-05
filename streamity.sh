#!/bin/bash
scriptVersion="1.0.3"

pidStoreFile="/tmp/streamity.conf"
logFolder="/var/log/streamity"

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
    echo "[$(date)] Fake log for $1."
    sleep 2
    done &
}


# Function to start the streaming flow
startFlow() {
    progInfo
    
    # check for variables to see if already running (later version)
    true > $pidStoreFile
    printf "Press [Enter] to start..."
    read -r _ || true

    exec 3> >(dvgrab - | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2 > "$logFolder/video.log" 2>&1 &)

    #debugService "video" >> $logFolder/video.log

    videoPID=$!

    #cat $videoPID
    echo "$videoPID" >> $pidStoreFile
    #cat $pidStoreFile

    sleep 5

    flatpak run com.obsproject.Studio --multi --profile "Partial Public Stream" --collection "Partial Public" > "$logFolder/obs1.log" 2>&1 &

    #debugService "obs1" >> $logFolder/obs1.log

    obs1PID=$!

    #cat $obs1PID
    echo "$obs1PID" >> $pidStoreFile
    #cat $pidStoreFile

    sleep 5

    flatpak run com.obsproject.Studio --multi --profile "Full Private Stream" --collection "Full Private" > "$logFolder/obs2.log" 2>&1 &

    #debugService "obs2" >> $logFolder/obs2.log

    obs2PID=$!

    #cat $obs2PID
    echo "$obs2PID" >> $pidStoreFile
    #cat $pidStoreFile
}

# Function to stop the streaming flow
stopFlow() {
    # check if variable exists
   
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