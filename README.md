# streamity
A custom shell script tool that starts services for streaming with Bash.

## Installation
Before installing make sure to change permissions for the `install.sh` file before trying to install:
```
chmod +x path/install.sh
```
Make sure the `path` in the above command is replaced with the file path. Then run the `install.sh` script:
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