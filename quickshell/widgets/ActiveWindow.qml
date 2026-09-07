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
      color: Fonts.colorPrimary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.lg
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
      color: Fonts.colorPrimary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.lg
      font.capitalization: Font.AllUppercase
      Layout.rightMargin: 5
    }

    Rectangle {
      id: appTitleTextRect

      readonly property int maxCharWidth: 60
      readonly property string elideChars: "..."

      color: "transparent"
      clip: true

      implicitHeight: currentActiveWindowTitle.height
      implicitWidth: currentActiveWindowTitle.width

      function truncateText(rawText) {
          const title = Boolean(rawText?.trim()) ? rawText?.trim() : "No title"
          if (rawText.length > appTitleTextRect.maxCharWidth) {
            return rawText.substring(0, appTitleTextRect.maxCharWidth - appTitleTextRect.elideChars.length) + appTitleTextRect.elideChars
          }
          return title
      }

      Text {
        id: currentActiveWindowTitle
        text: appTitleTextRect.truncateText(root.currentFocusedWindowTitle) 
        color: Fonts.colorNormal
        font.weight: Fonts.medium
        font.family: Fonts.mono
        font.pixelSize: Fonts.lg - 2
      }
    }

    Text {
      opacity: NiriService.hasNextWindow ? 0.8 : 0
      text: "󰛂"
      color: Fonts.colorPrimary
      font.weight: Fonts.black
      font.family: Fonts.mono
      font.pixelSize: Fonts.lg
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
