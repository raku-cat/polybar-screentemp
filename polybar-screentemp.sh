#!/bin/bash

# Config
backend="systemd"
executable="gammastep"
executable_path="gammastep"
screentemp="6500:4500"

invalidConfig() {
    echo "Invalid configuration: $1"
    exit 1
}

# Validate executable path
if ! command -v "$executable_path" >/dev/null 2>&1; then
    invalidConfig "Executable not found: $executable_path"
fi

# Validate config options
validateConfig() {
    case "$1" in
        backend)
            valid_options=("systemd" "daemonless")
            config_value="$backend"
            ;;
        executable)
            valid_options=("gammastep" "redshift")
            config_value="$executable"
            ;;
        screentemp)
            # Skip validation if backend is systemd
            if [ "$backend" = "systemd" ]; then
                return
            fi
            # Allow null value for screentemp
            if [ -z "$screentemp" ]; then
                return
            fi
            # Require valid non-decimal number for screentemp
            if ! [[ "$screentemp" =~ ^[0-9]+\:[0-9]+$ ]]; then
                invalidConfig "Invalid $1: $screentemp"
            fi
            return
            ;;
        *)
            invalidConfig "Unknown config type: $1"
            ;;
    esac

    if [[ ! " ${valid_options[*]} " =~ " $config_value " ]]; then
        invalidConfig "Invalid $1: $config_value"
    fi
}

validateConfig "backend"
validateConfig "executable"
validateConfig "screentemp"

# Backend actions mapping
declare -A backend_actions=(
    [systemd]="systemctl --user"
    [daemonless]="$executable_path"
)

# Validate backend and retrieve backend command
if [[ -v backend_actions["$backend"] ]]; then
    backendCommand="${backend_actions[$backend]}"
else
    invalidConfig "Invalid backend: $backend"
fi

# Evaluate program state
case $backend in
    systemd)
        $backendCommand is-active "$executable" --quiet && programState="on" || programState="off"
        ;;
    daemonless)
        executable_process=$(pgrep -f "$executable_path")
        if [ -n "$executable_process" ] && [ "$executable_process" -ne 0 ]; then
            programState="on"
        else
            programState="off"
        fi
        ;;
esac

# Begin script commands
case $1 in
    toggle)
        if [ "$programState" = "on" ]; then
            if [ "$backend" = "daemonless" ]; then
                killall $backendCommand
            else
                $backendCommand stop "$executable"
            fi
        else
            if [ "$backend" = "daemonless" ]; then
                $backendCommand -t "$screentemp"
            else
                $backendCommand start "$executable"
            fi
        fi
        ;;
    temperature)
        colorTemp=$("$executable_path" -p |& awk '/Color temperature:/ {print $NF}')
        case $programState in
            on)
                echo "$colorTemp"
                ;;
            off)
                echo "off"
                ;;
        esac
        ;;
esac
