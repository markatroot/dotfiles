import QtQuick
import QtQuick.Layouts
import "../config"

// One row of the themed tray context menu (see SystemTray.qml).
Rectangle {
    id: menuRow

    property string label: ""
    property string iconSource: ""
    property string leading: ""
    property string trailing: ""
    signal clicked()

    Layout.fillWidth: true
    implicitWidth: rowLayout.implicitWidth + 16
    implicitHeight: 26
    radius: 4
    color: rowMouse.containsMouse && enabled ? Theme.selection : "transparent"
    opacity: enabled ? 1 : 0.4

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Text {
            visible: menuRow.leading !== ""
            text: menuRow.leading
            color: Theme.accent
            font.family: Fonts.mono
            font.pixelSize: Fonts.sm
        }

        Image {
            visible: menuRow.iconSource !== ""
            source: menuRow.iconSource
            sourceSize.width: 14
            sourceSize.height: 14
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }

        Text {
            Layout.fillWidth: true
            text: menuRow.label.replace(/_(?!_)/g, "")
            color: rowMouse.containsMouse && menuRow.enabled ? Theme.white : Theme.fg
            font.family: Fonts.mono
            font.pixelSize: Fonts.sm
            elide: Text.ElideRight
        }

        Text {
            visible: menuRow.trailing !== ""
            text: menuRow.trailing
            color: Theme.brightBlack
            font.family: Fonts.mono
            font.pixelSize: Fonts.sm
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: menuRow.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: menuRow.clicked()
    }
}
