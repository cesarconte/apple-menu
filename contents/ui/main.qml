/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils // KCMLauncher
import org.kde.plasma.private.sessions as Sessions
import CachyOS.UI

PlasmoidItem {
    id: root

    Sessions.SessionManagement {
        id: sm
    }

    Sessions.SessionsModel {
        id: sessionsModel
    }

    // define exec system (call commands)
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"];

            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout);
            }

            exited(sourceName, stdout);
            disconnectSource(sourceName); // exec finished
        }

        function exec(cmd, onNewDataCallback) {
            if (!cmd || cmd.trim() === "") {
                return;
            }
            if (onNewDataCallback !== undefined) {
                callbacks[cmd] = onNewDataCallback;
            }
            connectSource(cmd);
        }
        signal exited(string sourceName, string stdout)
    }

    Connections {
        target: root
        function onExpandedChanged() {
            var rep = root.fullRepresentationItem;
            if (rep) {
                if (root.expanded) {
                    rep.forceActiveFocus();
                }
                rep.currentIndex = -1;
            }
        }
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: null

    fullRepresentation: FocusScope {
        id: fullRoot
        focus: true

        property int currentIndex: -1

        Component.onCompleted: {
            if (root.expanded) {
                forceActiveFocus();
            }
        }

        readonly property var menuItems: [
            aboutThisComputerItem,
            systemPreferencesItem,
            appStoreItem,
            forceQuitItem,
            sleepItem,
            restartItem,
            shutDownItem,
            lockScreenItem,
            logOutItem
        ]

        Layout.preferredWidth: 220
        Layout.preferredHeight: columnLayout.implicitHeight + 8
        implicitWidth: Layout.preferredWidth
        implicitHeight: Layout.preferredHeight

        function triggerCurrent(event) {
            if (currentIndex >= 0 && currentIndex < menuItems.length) {
                menuItems[currentIndex].clicked();
                if (event) {
                    event.accepted = true;
                }
            }
        }

        function triggerAction(actionName) {
            root.expanded = false;

            switch (actionName) {
                case "about":
                    soInfo.show();
                    soInfo.raise();
                    soInfo.requestActivate();
                    break;

                case "preferences":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.systemPreferencesSettings && Plasmoid.configuration.systemPreferencesSettings.trim() !== "") {
                        executable.exec(Plasmoid.configuration.systemPreferencesSettings);
                    } else {
                        KCMLauncher.openSystemSettings("");
                    }
                    break;

                case "appstore":
                    var appCmd = Plasmoid.configuration.appStoreSettings;
                    if (!appCmd || appCmd.trim() === "" || appCmd === "plasma-discover") {
                        appCmd = "shelly-ui";
                    }
                    executable.exec(appCmd);
                    break;

                case "forcequit":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.forceQuitSettings && Plasmoid.configuration.forceQuitSettings.trim() !== "" && plasmoid.configuration.forceQuitSettings !== "xkill") {
                        executable.exec(Plasmoid.configuration.forceQuitSettings);
                    } else {
                        executable.exec("qdbus6 org.kde.KWin /KWin killWindow || busctl --user call org.kde.KWin /KWin org.kde.KWin killWindow");
                    }
                    break;

                case "sleep":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.sleepSettings && Plasmoid.configuration.sleepSettings.trim() !== "" && plasmoid.configuration.sleepSettings !== "systemctl suspend") {
                        executable.exec(Plasmoid.configuration.sleepSettings);
                    } else {
                        if (sm.canSuspend) {
                            sm.suspend();
                        } else {
                            executable.exec("systemctl suspend");
                        }
                    }
                    break;

                case "restart":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.restartSettings && Plasmoid.configuration.restartSettings.trim() !== "" && plasmoid.configuration.restartSettings !== "/sbin/reboot") {
                        executable.exec(Plasmoid.configuration.restartSettings);
                    } else {
                        sm.requestReboot();
                    }
                    break;

                case "shutdown":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.shutDownSettings && Plasmoid.configuration.shutDownSettings.trim() !== "" && plasmoid.configuration.shutDownSettings !== "/sbin/shutdown now") {
                        executable.exec(Plasmoid.configuration.shutDownSettings);
                    } else {
                        sm.requestShutdown();
                    }
                    break;

                case "lock":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.lockScreenSettings && Plasmoid.configuration.lockScreenSettings.trim() !== "" && plasmoid.configuration.lockScreenSettings !== "qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock") {
                        executable.exec(Plasmoid.configuration.lockScreenSettings);
                    } else {
                        sm.lock();
                    }
                    break;

                case "logout":
                    if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.logOutSettings && Plasmoid.configuration.logOutSettings.trim() !== "" && plasmoid.configuration.logOutSettings !== "qdbus org.kde.ksmserver /KSMServer logout 0 0 0") {
                        executable.exec(Plasmoid.configuration.logOutSettings);
                    } else {
                        sm.requestLogout();
                    }
                    break;
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Down) {
                if (currentIndex < 0 || currentIndex >= menuItems.length - 1) {
                    currentIndex = 0;
                } else {
                    currentIndex++;
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                if (currentIndex <= 0) {
                    currentIndex = menuItems.length - 1;
                } else {
                    currentIndex--;
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Home) {
                currentIndex = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_End) {
                currentIndex = menuItems.length - 1;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                triggerCurrent(event);
            } else if (event.key === Qt.Key_Escape) {
                root.expanded = false;
                event.accepted = true;
            }
        }

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            anchors.margins: 4
            spacing: 1

            ListDelegate {
                id: aboutThisComputerItem
                isCurrent: fullRoot.currentIndex === 0
                text: i18n("About This Computer")
                onHovered: fullRoot.currentIndex = 0
                onClicked: fullRoot.triggerAction("about")
            }

            CachyMenuSeparator {
                Layout.fillWidth: true
            }

            ListDelegate {
                id: systemPreferencesItem
                isCurrent: fullRoot.currentIndex === 1
                text: i18n("System Preferences...")
                onHovered: fullRoot.currentIndex = 1
                onClicked: fullRoot.triggerAction("preferences")
            }

            ListDelegate {
                id: appStoreItem
                isCurrent: fullRoot.currentIndex === 2
                text: i18n("App Store...")
                onHovered: fullRoot.currentIndex = 2
                onClicked: fullRoot.triggerAction("appstore")
            }

            CachyMenuSeparator {
                Layout.fillWidth: true
            }

            ListDelegate {
                id: forceQuitItem
                isCurrent: fullRoot.currentIndex === 3
                text: i18n("Force Quit...")
                shortcutText: "⌥⌘⎋"
                onHovered: fullRoot.currentIndex = 3
                onClicked: fullRoot.triggerAction("forcequit")
            }

            CachyMenuSeparator {
                Layout.fillWidth: true
            }

            ListDelegate {
                id: sleepItem
                isCurrent: fullRoot.currentIndex === 4
                text: i18n("Sleep")
                onHovered: fullRoot.currentIndex = 4
                onClicked: fullRoot.triggerAction("sleep")
            }

            ListDelegate {
                id: restartItem
                isCurrent: fullRoot.currentIndex === 5
                text: i18n("Restart...")
                onHovered: fullRoot.currentIndex = 5
                onClicked: fullRoot.triggerAction("restart")
            }

            ListDelegate {
                id: shutDownItem
                isCurrent: fullRoot.currentIndex === 6
                text: i18n("Shut Down...")
                onHovered: fullRoot.currentIndex = 6
                onClicked: fullRoot.triggerAction("shutdown")
            }

            CachyMenuSeparator {
                Layout.fillWidth: true
            }

            ListDelegate {
                id: lockScreenItem
                isCurrent: fullRoot.currentIndex === 7
                text: i18n("Lock Screen")
                shortcutText: "⌃⌘Q"
                onHovered: fullRoot.currentIndex = 7
                onClicked: fullRoot.triggerAction("lock")
            }

            ListDelegate {
                id: logOutItem
                isCurrent: fullRoot.currentIndex === 8
                text: i18n("Log Out")
                shortcutText: "⇧⌘Q"
                onHovered: fullRoot.currentIndex = 8
                onClicked: fullRoot.triggerAction("logout")
            }
        }
    }

    SoInfo {
        id: soInfo
        onMoreInfoRequested: {
            if (Plasmoid.configuration.showAdvancedMode && Plasmoid.configuration.aboutThisComputerSettings && Plasmoid.configuration.aboutThisComputerSettings.trim() !== "") {
                executable.exec(Plasmoid.configuration.aboutThisComputerSettings);
            } else {
                KCMLauncher.openSystemSettings("kcm_about-distro");
            }
        }
    }

    Plasmoid.icon: Plasmoid.configuration.useCustomButtonImage && Plasmoid.configuration.customButtonImage ? Plasmoid.configuration.customButtonImage : Plasmoid.configuration.icon
}
