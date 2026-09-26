pragma Singleton

import QtQuick
import Quickshell

// Colors come from ~/.mark/dotfiles/rc/themerc via the environment niri was
// started with. Fallbacks (One Dark) apply when a variable isn't set.
QtObject {
  id: root

  function env(name, fallback) {
    return Quickshell.env(name) || fallback
  }

  readonly property color bg: env("THEME_BG", "#282c34")
  readonly property color bgAlt: env("THEME_BG_ALT", "#21252b")
  readonly property color fg: env("THEME_FG", "#abb2bf")

  readonly property color black: env("THEME_BLACK", "#21252b")
  readonly property color red: env("THEME_RED", "#e06c75")
  readonly property color green: env("THEME_GREEN", "#98c379")
  readonly property color yellow: env("THEME_YELLOW", "#e5c07b")
  readonly property color blue: env("THEME_BLUE", "#61afef")
  readonly property color magenta: env("THEME_MAGENTA", "#c678dd")
  readonly property color cyan: env("THEME_CYAN", "#56b6c2")
  readonly property color white: env("THEME_WHITE", "#dcdfe4")

  readonly property color brightBlack: env("THEME_BRIGHT_BLACK", "#5c6370")
  readonly property color brightRed: env("THEME_BRIGHT_RED", "#be5046")
  readonly property color brightGreen: env("THEME_BRIGHT_GREEN", "#a5e075")
  readonly property color brightYellow: env("THEME_BRIGHT_YELLOW", "#d19a66")
  readonly property color brightBlue: env("THEME_BRIGHT_BLUE", "#74b8f2")
  readonly property color brightMagenta: env("THEME_BRIGHT_MAGENTA", "#d38aea")
  readonly property color brightCyan: env("THEME_BRIGHT_CYAN", "#6bc9d4")
  readonly property color brightWhite: env("THEME_BRIGHT_WHITE", "#ffffff")

  readonly property color accent: env("THEME_ACCENT", "#61afef")
  readonly property color selection: env("THEME_SELECTION", "#3e4451")
  readonly property color gutter: env("THEME_GUTTER", "#4b5263")

  readonly property color primary: env("THEME_PRIMARY", blue)
  readonly property color success: env("THEME_SUCCESS", green)
  readonly property color danger: env("THEME_DANGER", red)
  readonly property color info: env("THEME_INFO", cyan)
  readonly property color warning: env("THEME_WARNING", yellow)
}
