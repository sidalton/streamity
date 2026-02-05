# streamity
A custom shell script for use with Bash to start two instances of OBS as well as a `dvgrab` pipe to `ffmpeg` to create an easily-usable DV video device.

## Installation
Change the directories to the streamity folder to make installation easier.
```
cd path/to/streamity-x.x
```
Before installing make sure to change permissions for the `install.sh` file before trying to install:
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
streamity [OPTION] [LOGGING]
```
### Options
- `--start` or `-s` will start all serivces.
- `--stop` or `-x` will stop all serivces.
- `--help` or `-h` will help.

### Logging
- `--log` or `-l` will enable logging and save the logs to `/var/log/streamity`.

## Example
The following command will stop the services and save the logs.
```
streamity --stop -l
```
