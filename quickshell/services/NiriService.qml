pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property var windows: []
  property var workspaces: []

  property string activeWindowName: " "
  property string activeWindowTitle: " "

  property real focusedWorkspaceId: 0

  property bool hasFocusedWindow: false

  property var nextWindow: null

  property var currentWindow: null

  property var lastFocusedWindow: null

  property var previousWindow: null

  property bool hasNextWindow: false

  property bool hasPreviousWindow: false

  property var window: null

  property int focusedWindowId: 0

  property int lastFocusedWindowId: 0

  function setWindowInfo(window) {
    root.activeWindowName = window?.app_id ?? " "
    root.activeWindowTitle = window?.title ?? " "
    root.hasFocusedWindow = Boolean(window?.app_id)

    root.lastFocusedWindow = root.currentWindow
    if (window) {
      const activeWorkspaceWindows = root.sortWindows(root.windows.filter((w) => w.workspace_id == window.workspace_id))
      const activeWindowIndex = activeWorkspaceWindows.findIndex((w) => w.id == window.id)
      root.hasNextWindow = Boolean(activeWorkspaceWindows?.[activeWindowIndex + 1])
      root.hasPreviousWindow = Boolean(activeWorkspaceWindows?.[activeWindowIndex - 1])
      root.nextWindow = activeWorkspaceWindows?.[activeWindowIndex + 1]
      root.previousWindow = activeWorkspaceWindows?.[activeWindowIndex - 1]
      root.currentWindow = activeWorkspaceWindows?.[activeWindowIndex]
    } else {
      root.hasNextWindow = false
      root.hasPreviousWindow = false
      root.nextWindow = null
      root.previousWindow = null
      root.currentWindow = null
    }

  }

  function sortWindows(windows) {
    return windows.sort((a, b) => {
      return a.layout.pos_in_scrolling_layout[0] - b.layout.pos_in_scrolling_layout[0]
    });
  }

  function tryParseJson(obj) {
    if (!obj) {
      return null
    }
    try {
      return JSON.parse(obj)
    } catch (e) {
      console.error('parse error', e)
      return null
    }
  }

  Process {
    id: niriEventStream
    command: ["niri", "msg", "--json", "event-stream"]
    running: true

    stdout: SplitParser {
      onRead: line => {
        try {
          var event = root.tryParseJson(line);
          if (
            event.WindowsChanged ||
            event.WindowOpenedOrChanged
          ) {
            allWindowsProcess.running = true
          }

          if (
            event.WindowFocusChanged ||
            event.WindowsChanged ||
            event.WindowOpenedOrChanged
          ) {
            focusedWindowProcess.running = true
          }

          if (event.WindowFocusChanged) {
            root.lastFocusedWindowId = root.focusedWindowId
            root.focusedWindowId = event.WindowFocusChanged.id
          }

          if (event.WorkspacesChanged) {
            root.workspaces = (event.WorkspacesChanged.workspaces?.filter((a) => a.active_window_id || a.is_focused) ?? []).sort((a, b) => {
              return a.id - b.id;
            })
          }

          if (event.WorkspaceActivated) {
            root.focusedWorkspaceId = event.WorkspaceActivated.id
          }
        } catch (e) {
          console.error(e)
        }
      }
    }
  }

  Process {
    id: focusedWindowProcess
    command: ["niri", "msg", "--json", "focused-window"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const output = root.tryParseJson(this.text)
        root.setWindowInfo(output)
      }
    }
  }

  Process {
    id: allWindowsProcess
    command: ["niri", "msg", "--json", "windows"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const windows = root.tryParseJson(this.text)
        root.windows = windows ?? []
      }
    }
  }


}
