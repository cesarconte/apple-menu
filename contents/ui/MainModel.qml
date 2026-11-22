/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Cesar Conte
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.ksysguard.sensors as Sensors
import CachyOS.UI

Item {
    id: root

    property string processor: ""
    property string graphics: ""
    property string memory: ""
    property string storage: ""
    property string osName: CachyTheme.distroName
    property string plasmaVersion: ""
    property string qtVersion: ""

    property alias infoModel: mainModel

    ListModel {
        id: mainModel
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const stdout = data["stdout"];
            disconnectSource(sourceName);
            if (stdout) {
                root.parseHardwareInfo(stdout);
            }
        }
    }

    Sensors.SensorDataModel {
        id: plasmaVersionModel
        sensors: ["os/plasma/plasmaVersion"]
        enabled: true
        onDataChanged: {
            const val = data(index(0, 0), Sensors.SensorDataModel.Value);
            if (val !== undefined && val !== null && String(val).trim() !== "") {
                root.plasmaVersion = String(val).trim();
                root.updateModel();
            }
        }
    }

    Sensors.SensorDataModel {
        id: qtVersionModel
        sensors: ["os/plasma/qtVersion"]
        enabled: true
        onDataChanged: {
            const val = data(index(0, 0), Sensors.SensorDataModel.Value);
            if (val !== undefined && val !== null && String(val).trim() !== "") {
                root.qtVersion = String(val).trim();
            }
        }
    }

    Sensors.SensorDataModel {
        id: osModel
        sensors: ["os/system/name"]
        enabled: true
        onDataChanged: {
            const val = data(index(0, 0), Sensors.SensorDataModel.Value);
            if (val !== undefined && val !== null && String(val).trim() !== "") {
                root.osName = String(val).trim();
                root.updateModel();
            }
        }
    }

    function parseHardwareInfo(stdout: string): void {
        const lines = stdout.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const colon = line.indexOf(":");
            if (colon === -1) continue;
            const key = line.substring(0, colon).trim();
            const val = line.substring(colon + 1).trim();
            if (key === "CPU") root.processor = val;
            else if (key === "GPU") root.graphics = val;
            else if (key === "MEM") root.memory = val;
            else if (key === "DISK") root.storage = val;
        }
        root.updateModel();
    }

    function updateModel(): void {
        mainModel.clear();
        if (root.processor.length > 0) {
            mainModel.append({ name: i18n("Processor"), value: root.processor });
        }
        if (root.graphics.length > 0) {
            mainModel.append({ name: i18n("Graphics"), value: root.graphics });
        }
        if (root.memory.length > 0) {
            mainModel.append({ name: i18n("Memory"), value: root.memory });
        }
        if (root.storage.length > 0) {
            mainModel.append({ name: i18n("Storage"), value: root.storage });
        }
        if (root.osName.length > 0) {
            mainModel.append({ name: i18n("OS"), value: root.osName });
        }
        if (root.plasmaVersion.length > 0) {
            mainModel.append({ name: i18n("Plasma"), value: root.plasmaVersion });
        }
    }

    Component.onCompleted: {
        const cmd = "sh -c '" +
            "CPU=$(grep -m1 \"model name\" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed \"s/^[ \t]*//\"); " +
            "GPU=$(lspci 2>/dev/null | grep -iE \"vga|3d|display\" | head -n1 | sed -E \"s/.*: //; s/ \\(rev .*\\)//\"); " +
            "MEM=$(free -h --si 2>/dev/null | awk \"/Mem:/ {print \\$2}\" | sed \"s/G/ GB/\"); " +
            "DISK=$(df -h / 2>/dev/null | awk \"NR==2 {print \\$2 \\\" (\\\" \\$4 \\\" free)\\\"\"); " +
            "echo \"CPU:$CPU\"; echo \"GPU:$GPU\"; echo \"MEM:$MEM\"; echo \"DISK:$DISK\"'";
        executable.connectSource(cmd);
        root.updateModel();
    }
}
