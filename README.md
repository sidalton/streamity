# streamity
A custom shell script for use with Bash to start two instances of OBS as well as a `dvgrab` pipe to `ffmpeg` to create an easily-usable DV video device.

## Installation
Change the directories to the streamity folder to make installation easier.
```
cd path/to/streamity-x.x
```
Before installing, make sure to change permissions for the `install.sh` file before trying to install:
```
chmod +x install.sh
```
Make sure the `path` in the above command is replaced with the file path (if you changed directories then that's not necessary). Then run the `install.sh` script:
```
sudo ./install.sh
```
> [!NOTE]
> Make sure to run the script as sudo!

## Using the script
### Usage
```
streamity [OPTION]
```
### Options
- `--start` or `-s` will start all serivces.
- `--stop` or `-x` will stop all serivces.
- `--help` or `-h` will show help.
- `--log` or `-l` will show the directory where logs are saved.

## Example
The following command will stop the services.
```
streamity --stop
```
## Troubleshooting
### Install Issues
```
Verification failed! The installation will be aborted.
```
This means that the hash in the CHECKSUM.sha512 file doesn't match the hashes of the scripts. You should redownload the files.
> [!NOTE]
> For versions prior to v1.0.3, hashes were not correct. While I wouldn't recommend using these versions, if you must use them, then comment out lines 11-16 in `install.sh` to bypass the verification.

#### If you find any other errors, please open an issue.
