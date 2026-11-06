#!/bin/sh
# satty-niri: listen for niri screenshots and open each one in Satty.
# Requires: niri (with ScreenshotCaptured IPC event), jq, satty, wl-clipboard

# Only allow one running instance
lock="${XDG_RUNTIME_DIR:-/tmp}/satty-niri.lock"
exec 9>"$lock"
flock -n 9 || { echo "satty-niri is already running" >&2; exit 0; }

open_satty() {
    path="$1"

    if [ -n "$path" ]; then
        # Wait briefly for niri to finish writing the file
        i=0
        while [ ! -s "$path" ] && [ "$i" -lt 20 ]; do
            sleep 0.05
            i=$((i + 1))
        done
    fi

    if [ -n "$path" ] && [ -s "$path" ]; then
        satty --filename "$path" \
              --output-filename "$path" \
              --copy-command wl-copy \
              --early-exit &
    else
        # No saved file (e.g. screenshot-path null): use the clipboard
        (wl-paste --type image/png | satty --filename - \
              --copy-command wl-copy \
              --early-exit) &
    fi
}

# Reconnect if the event stream ends (e.g. niri config reload hiccup)
while true; do
    niri msg --json event-stream 2>/dev/null |
        jq --unbuffered -r 'select(.ScreenshotCaptured) | (.ScreenshotCaptured.path // "")' |
        while IFS= read -r path; do
            open_satty "$path"
        done

    # Stop if niri itself is gone
    niri msg version >/dev/null 2>&1 || exit 0
    sleep 1
done
