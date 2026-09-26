#!/bin/bash
# Renders niri config templates (*.kdl.in) with colors from themerc.
# niri watches its config, so the new colors apply as soon as this runs.

source "/home/$USER/.mark/dotfiles/rc/themerc"

dir="$(dirname "$(realpath "$0")")/../config"
vars='${THEME_ACCENT} ${THEME_SELECTION} ${THEME_BG} ${THEME_DANGER}'

for template in "$dir"/*.kdl.in; do
  out="${template%.in}"
  envsubst "$vars" < "$template" > "$out.tmp" && mv "$out.tmp" "$out"
done
