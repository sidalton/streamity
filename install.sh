#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please run 'sudo ./install.sh'"
   exit 1
fi

# Housekeeping messages
echo "Streamity Installer v1.0. Created by S.I. Dalton."
echo "This script will install Streamity on your system."
read -p "Press [Enter] to continue with the installation or press [Ctrl+C] to cancel..." || true

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

# Create necessary folders and files
mkdir /var/log/streamity
sudo chown "$USER":"$USER" /var/log/streamity
touch /tmp/streamity.conf

echo "Installation complete. You can now run Streamity using the command 'streamity'."
echo "For help, run 'streamity --help'."