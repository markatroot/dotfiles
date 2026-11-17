#!/bin/bash

if [ -f "/home/$USER/Documents/Temp/whereami" ]; then

  if [ -d "$(cat /home/$USER/Documents/Temp/whereami)" ]; then
    echo "$(cat /home/$USER/Documents/Temp/whereami)"
  else
    echo "/home/$USER"
  fi

else
  echo "/home/$USER"
fi
