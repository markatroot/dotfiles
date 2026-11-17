import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services"
import "../config"

RowLayout {
  id: root
  Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
  Layout.fillHeight: true

  property string title: UmbrielService.activeWindowTitle

  property string name: UmbrielService.activeWindowName

  property var currentWindow: UmbrielService.currentWindow

  property string lastFocusedWindowTitle: ""

  property string currentFocusedWindowTitle: ""

  onCurrentWindowChanged: {
    root.lastFocusedWindowTitle = UmbrielService.lastFocusedWindow?.title ?? ""
    root.currentFocusedWindowTitle = UmbrielService.currentWindow?.title ?? ""
  }

  RowLayout {

    id: windowInfoRow

    spacing: 0

    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

    visible: UmbrielService.hasFocusedWindow

    Text {
      opacity: UmbrielService.hasPreviousWindow ? 0.8 : 0
      text: "󰛁"
      color: Theme.primary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl
      Layout.rightMargin: 5

      MouseArea {
        anchors.fill: parent
        onClicked: () => {
          UmbrielService.action("window-focus-left")
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

      // Behavior on implicitWidth {
      //   NumberAnimation { duration: 750; easing.type: Easing.OutCubic }
      // }

      Text {
        id: currentActiveWindowTitle
        width: Math.min(implicitWidth, appTitleTextRect.maxWidth)
        elide: Text.ElideLeft
        text: root.currentFocusedWindowTitle?.trim() || "No title"
        color: Theme.fg
        font.weight: Fonts.medium
        font.family: Fonts.mono
        font.pixelSize: Fonts.lg - 1
      }
    }

    Text {
      opacity: UmbrielService.hasNextWindow ? 0.8 : 0
      text: "󰛂"
      color: Theme.primary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.xxl
      Layout.leftMargin: 8

      MouseArea {
        anchors.fill: parent
        onClicked: () => {
          UmbrielService.action("window-focus-right")
        }
      }
    }

  }
}
