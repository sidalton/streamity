#!/bin/sh

# Housekeeping messages
echo "Streamity Installer v0.1.1. Created by S.I. Dalton."
echo "This script will install Streamity on your system."
read -p "Press [Enter] to continue with the installation..."

folderDir="$(cd "$(dirname "$0")" && pwd)"

# Verify the script
if sha512sum -c "$folderDir/CHECKSUM.sha512" >/dev/null 2>&1; then
    echo "Verification successful."
else
    echo "Verification failed! The installation will be aborted."
    exit 1
fi

# Install the main script
sudo mv "$folderDir/streamity.sh" /usr/local/bin/streamity
sudo chmod +x /usr/local/bin/streamity

mkdir -p /var/log/streamity

echo "Installation complete. You can now run Streamity using the command 'streamity'."
echo "For help, run 'streamity --help'."