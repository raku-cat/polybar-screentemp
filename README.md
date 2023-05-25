# polybar-screentemp
## Features
- Display of current screen temperature
- Toggling of temperature adjustment on/off
- Supports Gammastep and Redshift
- Supports control via systemd and daemonless (i.e. send commands directly to the program)


## Configuration 
Configuration is done within the script itself defaults have been left in for a bit of reference, and an explanation of the options are as follows: <br />
- `backend`:  Valid values are `systemd` and `daemonless`.
- `executable`: Valid values are `gammastep` and `redshift`.
- `executable_path`: If your installation is in a nonstandard location or not in your path place it here, otherwise can likely be the same as your `executable` value.
- `screentemp`: Only used with the `daemonless` backend configuration, should be in the format `DAYTEMP:NIGHTTEMP`, will be overriden if you have the ini for gammashift/redshift set up.

## Module example
Assumes script is placed in `~/.config/polybar/scripts/`

```
[module/screentemp]
type = custom/script
format-prefix = " "
exec = ~/.config/polybar/scripts/polybar-screentemp.sh temperature
click-left = ~/.config/polybar/scripts/polybar-screentemp.sh toggle
interval=10
```
