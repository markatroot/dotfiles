#!/bin/sh
# Start PipeWire, pipewire-pulse and WirePlumber in order (for OpenRC / non-systemd).

: "${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}"

# Stop any old instances so this is safe to re-run
pkill -x wireplumber
pkill -x pipewire-pulse
pkill -x pipewire

# Wait for old processes to exit
while pgrep -x pipewire >/dev/null; do sleep 0.1; done

# Start PipeWire and wait (up to 5s) for its socket
pipewire &
i=0
while [ ! -S "$XDG_RUNTIME_DIR/pipewire-0" ]; do
    sleep 0.1
    i=$((i + 1))
    [ "$i" -ge 50 ] && { echo "pipewire did not start" >&2; exit 1; }
done

# PipeWire is ready: start the rest
pipewire-pulse &
wireplumber &
