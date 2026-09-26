#!/bin/bash
# Launches foot with colors from themerc ($THEME_* in niri's environment).
# Any unset variable is skipped, so foot.ini's own [colors-dark] values apply.

opts=()
color() {
  local value="${!2}"
  [ -n "$value" ] && opts+=(-o "colors-dark.$1=${value#\#}")
}

color background THEME_BG
color foreground THEME_FG
color regular0 THEME_BLACK
color regular1 THEME_RED
color regular2 THEME_GREEN
color regular3 THEME_YELLOW
color regular4 THEME_BLUE
color regular5 THEME_MAGENTA
color regular6 THEME_CYAN
color regular7 THEME_WHITE
color bright0 THEME_BRIGHT_BLACK
color bright1 THEME_BRIGHT_RED
color bright2 THEME_BRIGHT_GREEN
color bright3 THEME_BRIGHT_YELLOW
color bright4 THEME_BRIGHT_BLUE
color bright5 THEME_BRIGHT_MAGENTA
color bright6 THEME_BRIGHT_CYAN
color bright7 THEME_BRIGHT_WHITE
color selection-background THEME_SELECTION

exec foot "${opts[@]}" "$@"
