import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Minimal Quickshell notification popup.
//
// Usage: put this file next to your shell.qml as "Notifications.qml"
// and load it from shell.qml, e.g.:
//
//   Notifications {}
//
// It creates its own NotificationServer, so don't declare another one
// unless you want to route notifications elsewhere too.

Scope {
  id: root

  // ---- Tunables -----------------------------------------------------
  property int popupWidth: 340
  property int spacing: 8
  property int margin: 16
  property int defaultTimeoutMs: 6000
  property color bg: "#1e1e2e"
  property color fg: "#cdd6f4"
  property color subFg: "#a6adc8"
  property color lowColor: "#89b4fa"
  property color normalColor: "#89b4fa"
  property color criticalColor: "#f38ba8"

  NotificationServer {
    id: notifServer
    keepOnReload: true
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true

    onNotification: function (notification) {
      notification.tracked = true
      notifModel.append({
        notification: notification
      })
    }
  }

  ListModel {
    id: notifModel
  }

  // One popup panel per screen, anchored top-right
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors.top: true
      anchors.right: true

      margins.top: root.margin
      margins.right: root.margin

      implicitWidth: root.popupWidth
      implicitHeight: column.implicitHeight

      color: "transparent"

      exclusiveZone: 0
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "quickshell-notifications"

      ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
          model: notifModel

          delegate: Rectangle {
            id: card
            required property var notification

            Layout.fillWidth: true
            implicitHeight: content.implicitHeight + 24
            radius: 5
            color: root.bg
            // border.width: 1
            // border.color: {
            //   switch (notification.urgency) {
            //     case NotificationUrgency.Critical: return root.criticalColor
            //     case NotificationUrgency.Low: return root.lowColor
            //     default: return root.normalColor
            //   }
            // }

            // Slide/fade in
            opacity: 0
            Component.onCompleted: opacity = 1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
              anchors.fill: parent
              onClicked: {
                notification.dismiss()
                removeSelf()
              }
            }

            function removeSelf() {
              for (let i = 0; i < notifModel.count; i++) {
                if (notifModel.get(i).notification === notification) {
                  notifModel.remove(i)
                  break
                }
              }
            }

            Timer {
              interval: notification.expireTimeout > 0 ? notification.expireTimeout : root.defaultTimeoutMs
              running: true
              onTriggered: card.removeSelf()
            }

            RowLayout {
              id: content
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              Image {
                visible: notification.image !== "" || notification.appIcon !== ""
                source: notification.image !== "" ? notification.image : ("image://icon/" + notification.appIcon)
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                fillMode: Image.PreserveAspectFit
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                  text: notification.summary
                  color: root.fg
                  font.bold: true
                  font.pixelSize: 13
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                }

                Text {
                  visible: notification.body !== ""
                  text: notification.body
                  color: root.subFg
                  font.pixelSize: 12
                  wrapMode: Text.Wrap
                  Layout.fillWidth: true
                  maximumLineCount: 3
                  elide: Text.ElideRight
                  textFormat: Text.StyledText
                }

                RowLayout {
                  visible: notification.actions.length > 0
                  spacing: 6
                  Layout.topMargin: 4

                  Repeater {
                    model: notification.actions

                    Rectangle {
                      required property var modelData
                      implicitWidth: actionLabel.implicitWidth + 16
                      implicitHeight: 24
                      radius: 5
                      color: "#313244"

                      Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: root.fg
                        font.pixelSize: 11
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: {
                          modelData.invoke()
                          card.removeSelf()
                        }
                      }
                    }
                  }
                }
              }

              Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignTop
                radius: 10
                color: "transparent"

                Text {
                  anchors.centerIn: parent
                  text: "✕"
                  color: root.subFg
                  font.pixelSize: 11
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    notification.dismiss()
                    card.removeSelf()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
