#!/bin/sh
# Start PipeWire, pipewire-pulse and WirePlumber in order (for OpenRC / non-systemd).
#
# Safe to run from nested compositor sessions: if PipeWire is already running on
# this D-Bus session bus, it is left alone and only missing daemons are started.
# A PipeWire left over from an older login (different bus) is restarted.
# Pass --restart to force a full restart.

: "${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}"

# Start a daemon in its own session so it survives the parent compositor
# (or terminal) being closed with Ctrl-C.
start() { setsid -f "$@" >/dev/null 2>&1 </dev/null; }

# True if a pipewire process is running on our D-Bus session bus.
pipewire_is_ours() {
    for pid in $(pgrep -x pipewire); do
        bus=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null |
            sed -n 's/^DBUS_SESSION_BUS_ADDRESS=//p')
        [ "$bus" = "$DBUS_SESSION_BUS_ADDRESS" ] && return 0
    done
    return 1
}

if [ "$1" != "--restart" ] && pipewire_is_ours && [ -S "$XDG_RUNTIME_DIR/pipewire-0" ]; then
    pgrep -x pipewire-pulse >/dev/null || start pipewire-pulse
    pgrep -x wireplumber >/dev/null || start wireplumber
    exit 0
fi

# Stop any old instances
pkill -x wireplumber
pkill -x pipewire-pulse
pkill -x pipewire

# Wait for old processes to exit
while pgrep -x pipewire >/dev/null; do sleep 0.1; done

# Start PipeWire and wait (up to 5s) for its socket
start pipewire
i=0
while [ ! -S "$XDG_RUNTIME_DIR/pipewire-0" ]; do
    sleep 0.1
    i=$((i + 1))
    [ "$i" -ge 50 ] && { echo "pipewire did not start" >&2; exit 1; }
done

# PipeWire is ready: start the rest
start pipewire-pulse
start wireplumber
