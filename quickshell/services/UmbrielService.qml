pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Workspace and window state from Umbriel's IPC event stream.
// `umbriel subscribe workspaces,windows` prints one JSON line per change:
//   {"event": "workspaces" | "windows", "data": [...]}
// Each payload is a full snapshot, so state is replaced, never merged.
// Field reference: https://docs.noctalia.dev/umbriel/ipc/
Singleton {
  id: root

  property var windows: []
  property var workspaces: []

  property string activeWindowName: " "
  property string activeWindowTitle: " "

  // Umbriel IDs are strings.
  property string focusedWorkspaceId: ""

  property bool hasFocusedWindow: false

  property var nextWindow: null

  property var currentWindow: null

  property var lastFocusedWindow: null

  property var previousWindow: null

  property bool hasNextWindow: false

  property bool hasPreviousWindow: false

  property string focusedWindowId: ""

  property string lastFocusedWindowId: ""

  // Actions run through `umbriel msg <action> [args...]`.
  function action(...args) {
    Quickshell.execDetached(["umbriel", "msg", ...args])
  }

  function focusWorkspace(workspace) {
    root.action("workspace-switch", String(workspace.index), "--output", workspace.output)
  }

  // The seat-focused window, or (while a layer surface such as the clipboard
  // popup holds the keyboard) the focused workspace's remembered window.
  function findFocusedWindow() {
    const active = root.windows.find((w) => w.active)
    if (active) {
      return active
    }
    const workspace = root.workspaces.find((ws) => ws.focused)
    if (!workspace?.focused_window) {
      return null
    }
    return root.windows.find((w) => w.id == workspace.focused_window) ?? null
  }

  function setWindowInfo(window) {
    root.activeWindowName = window?.app_id ?? " "
    root.activeWindowTitle = window?.title ?? " "
    root.hasFocusedWindow = Boolean(window?.app_id)

    if ((window?.id ?? "") != root.focusedWindowId) {
      root.lastFocusedWindowId = root.focusedWindowId
      root.focusedWindowId = window?.id ?? ""
      root.lastFocusedWindow = root.currentWindow
    }

    if (window) {
      const activeWorkspaceWindows = root.sortWindows(root.windows.filter((w) => w.workspace == window.workspace))
      const activeWindowIndex = activeWorkspaceWindows.findIndex((w) => w.id == window.id)
      root.hasNextWindow = Boolean(activeWorkspaceWindows?.[activeWindowIndex + 1])
      root.hasPreviousWindow = Boolean(activeWorkspaceWindows?.[activeWindowIndex - 1])
      root.nextWindow = activeWorkspaceWindows?.[activeWindowIndex + 1] ?? null
      root.previousWindow = activeWorkspaceWindows?.[activeWindowIndex - 1] ?? null
      root.currentWindow = activeWorkspaceWindows?.[activeWindowIndex] ?? window
    } else {
      root.hasNextWindow = false
      root.hasPreviousWindow = false
      root.nextWindow = null
      root.previousWindow = null
      root.currentWindow = null
    }
  }

  // Scrolling-strip order: column, then row. Floating windows report -1.
  function sortWindows(windows) {
    return windows.sort((a, b) => (a.column - b.column) || (a.row - b.row))
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
    id: umbrielEventStream
    command: ["umbriel", "subscribe", "workspaces,windows"]
    running: true

    stdout: SplitParser {
      onRead: line => {
        const event = root.tryParseJson(line)
        if (!event?.event || !Array.isArray(event.data)) {
          return
        }

        if (event.event === "workspaces") {
          // Show occupied workspaces plus the active one on each output.
          root.workspaces = event.data
            .filter((ws) => ws.occupied || ws.active)
            .sort((a, b) => a.output.localeCompare(b.output) || a.index - b.index)
          root.focusedWorkspaceId = event.data.find((ws) => ws.focused)?.id ?? ""
        }

        if (event.event === "windows") {
          root.windows = event.data
        }

        root.setWindowInfo(root.findFocusedWindow())
      }
    }

    // Restart the stream if it ends (e.g. Umbriel restarted).
    onRunningChanged: {
      if (!running) {
        restartTimer.start()
      }
    }
  }

  Timer {
    id: restartTimer
    interval: 1000
    onTriggered: umbrielEventStream.running = true
  }
}
