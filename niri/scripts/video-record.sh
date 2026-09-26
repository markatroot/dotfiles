#!/bin/bash

NOW=$(date '+%Y-%m-%d_%H:%M:%S')
FILENAME="${NOW}.mp4"
DIR=/home/$USER/Videos/Records
  
CONTENT="$(cat /tmp/record)"
if [ "$CONTENT" = "1" ]; then
  pkill wf-recorder & echo 0 > /tmp/record
else
  wf-recorder -g "$(slurp)" -f "$DIR/$FILENAME" & echo 1 > /tmp/record
fi
