/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import CachyOS.UI

KCM.SimpleKCM {
    id: configHelp

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: CachyTheme.spacingLarge

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 400)
            fillMode: Image.PreserveAspectFit
            source: "images/kpple_banner.png"
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 360)
            spacing: CachyTheme.spacingSmall

            CachyHeading {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                horizontalAlignment: Text.AlignHCenter
                text: i18n("Apple Menu for CachyOS")
                level: 2
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                horizontalAlignment: Text.AlignHCenter
                text: i18n("macOS 27 Golden Gate Liquid Glass Menu for KDE Plasma 6")
                color: CachyPalette.textSecondary
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 320)
            spacing: CachyTheme.spacingSmall

            CachyButton {
                Layout.fillWidth: true
                pillStyle: true
                iconName: "help-about"
                text: i18n("Consult the User's Guide")
                onClicked: Qt.openUrlExternally("https://github.com/cesarconte/apple-menu")
            }

            CachyButton {
                Layout.fillWidth: true
                pillStyle: true
                iconName: "tools-report-bug"
                text: i18n("Report an Issue")
                onClicked: Qt.openUrlExternally("https://github.com/cesarconte/apple-menu/issues")
            }

            CachyButton {
                Layout.fillWidth: true
                pillStyle: true
                iconName: "help-donate"
                text: i18n("Support Development")
                onClicked: Qt.openUrlExternally("https://github.com/cesarconte/apple-menu")
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Designed and maintained for CachyOS and KDE Plasma 6.")
            font.pixelSize: 11
            color: CachyPalette.textMuted
            wrapMode: Text.WordWrap
        }
    }
}
