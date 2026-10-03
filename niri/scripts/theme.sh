#!/bin/bash
# Renders config templates (*.in) with colors from themerc.
# niri watches its config, so the new colors apply as soon as this runs.
# foot reads colors.ini on launch, so new terminals pick up the new colors.

source "/home/$USER/.mark/dotfiles/rc/themerc"

root="$(dirname "$(realpath "$0")")/../.."

vars='${THEME_MAGENTA} ${THEME_PRIMARY} ${THEME_SELECTION} ${THEME_BG} ${THEME_DANGER}'
for template in "$root"/niri/config/*.kdl.in; do
  out="${template%.in}"
  envsubst "$vars" < "$template" > "$out.tmp" && mv "$out.tmp" "$out"
done

# foot wants RRGGBB, so strip the leading # from each color
template="$root/foot/colors.ini.in"
out="${template%.in}"
envsubst < "$template" | sed 's/#\([0-9a-fA-F]\{6\}\)/\1/g' > "$out.tmp" && mv "$out.tmp" "$out"
