import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services"
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property string title: NiriService.activeWindowTitle

  property string name: NiriService.activeWindowName

  property var currentWindow: NiriService.currentWindow

  property string lastFocusedWindowTitle: ""

  property string currentFocusedWindowTitle: ""

  onCurrentWindowChanged: {
    root.lastFocusedWindowTitle = NiriService.lastFocusedWindow?.title ?? ""
    root.currentFocusedWindowTitle = NiriService.currentWindow?.title ?? ""
  }

  RowLayout {

    id: windowInfoRow

    spacing: 0

    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

    visible: NiriService.hasFocusedWindow

    Text {
      opacity: NiriService.hasPreviousWindow ? 0.8 : 0
      text: "󰛁"
      color: Theme.primary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl
      Layout.rightMargin: 5

      MouseArea {
        anchors.fill: parent
        onClicked: () => {
          Quickshell.execDetached(["niri", "msg", "action", "focus-column-left"])
        }
      }
    }

    Text {
      id: appName
      leftPadding: 4
      rightPadding: 4
      text: root.name
      color: Theme.primary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.lg
      font.capitalization: Font.AllUppercase
      Layout.rightMargin: 5
    }

    Rectangle {
      id: appTitleTextRect

      readonly property int maxWidth: 600

      color: "transparent"
      clip: true

      implicitHeight: currentActiveWindowTitle.height
      implicitWidth: currentActiveWindowTitle.width

      Behavior on implicitWidth {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
      }

      Text {
        id: currentActiveWindowTitle
        width: Math.min(implicitWidth, appTitleTextRect.maxWidth)
        elide: Text.ElideRight
        text: root.currentFocusedWindowTitle?.trim() || "No title"
        color: Theme.fg
        font.weight: Fonts.medium
        font.family: Fonts.mono
        font.pixelSize: Fonts.lg - 1
      }
    }

    Text {
      opacity: NiriService.hasNextWindow ? 0.8 : 0
      text: "󰛂"
      color: Theme.primary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl
      Layout.leftMargin: 8

      MouseArea {
        anchors.fill: parent
        onClicked: () => {
          Quickshell.execDetached(["niri", "msg", "action", "focus-column-right"])
        }
      }
    }

  }
}
