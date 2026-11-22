/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyWindow {
    id: aboutWindow

    visible: false
    width: 320
    height: 440
    minimumWidth: 300
    minimumHeight: 400
    maximumWidth: 360
    maximumHeight: 480
    closable: true
    minimizable: false
    maximizable: false
    resizable: false
    showTitleBarDivider: false
    windowTitle: i18n("About This Computer")

    x: Screen.width > 0 ? Math.round((Screen.width - width) / 2) : 100
    y: Screen.height > 0 ? Math.round((Screen.height - height) / 2) : 100

    signal moreInfoRequested()

    Shortcut {
        sequence: "Escape"
        onActivated: aboutWindow.close()
    }

    MainModel {
        id: mainModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: CachyTheme.marginWindow
        anchors.topMargin: CachyTheme.titleBarHeight + CachyTheme.spacingSmall
        spacing: CachyTheme.spacingMedium

        // System / Hardware Logo
        CachyIcon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            name: "computer"
            size: 64
            color: CachyTheme.accentColor
        }

        // Title and OS Name
        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: CachyTheme.spacingTiny

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                horizontalAlignment: Text.AlignHCenter
                text: CachyTheme.distroName.length > 0 ? CachyTheme.distroName : i18n("CachyOS")
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: CachyPalette.text
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                horizontalAlignment: Text.AlignHCenter
                text: mainModel.plasmaVersion.length > 0
                    ? i18n("Plasma %1", mainModel.plasmaVersion)
                    : CachyTheme.desktopShell
                font.pixelSize: 12
                color: CachyPalette.textSecondary
            }
        }

        // Specifications List
        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.fillHeight: true
            spacing: 6

            Repeater {
                model: mainModel.infoModel

                RowLayout {
                    id: specRow
                    required property var model

                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: CachyTheme.spacingSmall

                    Text {
                        Layout.preferredWidth: 70
                        Layout.minimumWidth: 0
                        horizontalAlignment: Text.AlignRight
                        text: specRow.model.name + ":"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: CachyPalette.textSecondary
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: specRow.model.value
                        font.pixelSize: 11
                        color: CachyPalette.text
                        wrapMode: Text.WordWrap
                        elide: Text.ElideNone
                    }
                }
            }
        }

        // Pill Button
        CachyButton {
            Layout.alignment: Qt.AlignHCenter
            pillStyle: true
            text: i18n("More info...")
            onClicked: aboutWindow.moreInfoRequested()
        }
    }
}
