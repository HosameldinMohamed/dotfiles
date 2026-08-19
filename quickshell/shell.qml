import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

ShellRoot {
    component PolledText: Item {
        id: poll
        required property var command
        property int interval: 2000
        property string fallback: "--"
        property string text: fallback
        visible: false
        width: 0
        height: 0

        function refresh() {
            proc.exec(command)
        }

        Process {
            id: proc
            stdout: StdioCollector {
                onStreamFinished: {
                    const out = this.text.trim()
                    poll.text = out.length > 0 ? out : poll.fallback
                }
            }
        }

        Timer {
            running: true
            repeat: true
            interval: poll.interval
            onTriggered: poll.refresh()
        }

        Component.onCompleted: poll.refresh()
    }

    component ActionChip: Rectangle {
        id: chip
        required property string label
        property string leftCommand: ""
        property string rightCommand: ""
        property color fg: "#cdd6f4"
        property color bg: "#252b45"
        property color borderCol: "#6c77a8"

        implicitHeight: 26
        implicitWidth: Math.max(32, labelText.implicitWidth + 14)
        radius: 11
        color: bg
        border.width: 1
        border.color: chip.borderCol

        Text {
            id: labelText
            anchors.centerIn: parent
            text: chip.label
            color: chip.fg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton && chip.rightCommand.length > 0) {
                    Quickshell.execDetached(["sh", "-lc", chip.rightCommand])
                } else if (chip.leftCommand.length > 0) {
                    Quickshell.execDetached(["sh", "-lc", chip.leftCommand])
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            screen: modelData

            anchors {
                left: true
                top: true
                right: true
            }

            margins {
                left: 14
                top: 10
                right: 14
            }

            implicitHeight: 46
            color: "transparent"
            aboveWindows: true

            Rectangle {
                id: surface
                anchors.fill: parent
                radius: 16
                color: "#d01e1e2e"
                border.width: 1
                border.color: "#6ccdd6f4"

                RowLayout {
                    id: rootRow
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6
                    spacing: 8

                    RowLayout {
                        spacing: 6

                        Repeater {
                            model: Hyprland.workspaces

                            Rectangle {
                                id: wsChip
                                required property HyprlandWorkspace modelData

                                implicitHeight: 26
                                implicitWidth: Math.max(34, wsLabel.implicitWidth + 16)
                                radius: 13
                                color: wsChip.modelData.focused
                                       ? "#89c2d9"
                                       : (wsChip.modelData.active ? "#5a6f93" : "#2a2f47")
                                border.width: wsChip.modelData.urgent ? 2 : 1
                                border.color: wsChip.modelData.urgent ? "#f38ba8" : "#6c7086"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 160
                                    }
                                }

                                Text {
                                    id: wsLabel
                                    anchors.centerIn: parent
                                    text: wsChip.modelData.name
                                    color: wsChip.modelData.focused ? "#11111b" : "#cdd6f4"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: wsChip.modelData.focused
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: wsChip.modelData.activate()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: "#4c566a"
                        opacity: 0.65
                    }

                    RowLayout {
                        spacing: 0

                        ActionChip {
                            label: ""
                            leftCommand: "playerctl previous"
                            fg: "#a6e3a1"
                            bg: "#1f2a1f"
                            borderCol: "#4fa06a"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "playerctl position 10-"
                            fg: "#a6e3a1"
                            bg: "#1f2a1f"
                            borderCol: "#4fa06a"
                        }

                        ActionChip {
                            id: playerControlChip
                            fg: "#a6e3a1"
                            bg: "#1f2a1f"
                            borderCol: "#4fa06a"

                            PolledText {
                                id: playerControlText
                                interval: 1000
                                fallback: ""
                                command: ["sh", "-lc", "~/.config/waybar/scripts/player_control.sh | head -n 1"]
                            }

                            label: playerControlText.text
                            leftCommand: "~/.config/waybar/scripts/player_control.sh play-pause"
                            rightCommand: "~/.config/waybar/scripts/player_control.sh switch-player"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "playerctl position 10+"
                            fg: "#a6e3a1"
                            bg: "#1f2a1f"
                            borderCol: "#4fa06a"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "playerctl next"
                            fg: "#a6e3a1"
                            bg: "#1f2a1f"
                            borderCol: "#4fa06a"
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: "#4c566a"
                        opacity: 0.65
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 11
                        color: "#1a1b26"
                        border.width: 1
                        border.color: "#2f3549"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            elide: Text.ElideRight
                            text: Hyprland.activeToplevel?.title ?? "Desktop"
                            color: "#cdd6f4"
                            font.family: "IBM Plex Sans"
                            font.pixelSize: 12
                        }
                    }

                    RowLayout {
                        spacing: 0

                        ActionChip {
                            label: "󰅙"
                            leftCommand: "hyprctl dispatch killactive"
                        }

                        ActionChip {
                            id: submapChip
                            label: submapState.text
                            leftCommand: "~/.config/waybar/scripts/toggle_mouse_move_submap.sh"

                            PolledText {
                                id: submapState
                                interval: 1000
                                fallback: "󰌌"
                                command: ["sh", "-lc", "hyprctl submap | awk '$1==\"mouseMove\"{print \"󰍽\"; next} {print \"󰌌\"}'"]
                            }
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "hyprctl keyword cursor:no_warps true && hyprctl dispatch cyclenext && hyprctl keyword cursor:no_warps false"
                            rightCommand: "hyprctl keyword cursor:no_warps true && hyprctl dispatch cyclenext prev && hyprctl keyword cursor:no_warps false"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "hyprctl keyword cursor:no_warps true && hyprctl dispatch movetoworkspace r-1 && hyprctl keyword cursor:no_warps false"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "hyprctl keyword cursor:no_warps true && hyprctl dispatch movetoworkspace r+1 && hyprctl keyword cursor:no_warps false"
                        }

                        ActionChip {
                            id: fullscreenChip
                            label: fullscreenState.text
                            leftCommand: "hyprctl dispatch fullscreen 1"

                            PolledText {
                                id: fullscreenState
                                interval: 1000
                                fallback: ""
                                command: ["sh", "-lc", "hyprctl activewindow | grep -i 'fullscreen:' | awk '{print ($2 == \"1\" ? \"\" : \"\")}'"]
                            }
                        }

                        ActionChip {
                            id: floatChip
                            label: floatState.text
                            leftCommand: "hyprctl dispatch togglefloating"

                            PolledText {
                                id: floatState
                                interval: 1000
                                fallback: ""
                                command: ["sh", "-lc", "hyprctl activewindow | grep -i 'floating:' | awk '{print ($2 == \"1\" ? \"\" : \"\")}'"]
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: "#4c566a"
                        opacity: 0.65
                    }

                    RowLayout {
                        spacing: 6

                        ActionChip {
                            label: ""
                            leftCommand: "google-chrome-stable"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "konsole"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "com.spotify.Client"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: "󰒱"
                            leftCommand: "slack"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "google-chrome-stable --profile-directory=Default --app=https://web.whatsapp.com"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: "󰊻"
                            leftCommand: "google-chrome-stable --profile-directory=Default --app=https://teams.microsoft.com"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: "󰴢"
                            leftCommand: "google-chrome-stable --profile-directory=Default --app=https://outlook.office.com"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "dolphin"
                            fg: "#f5c2e7"
                        }

                        ActionChip {
                            id: notificationChip
                            label: notificationState.text
                            leftCommand: "swaync-client -t -sw"
                            rightCommand: "swaync-client -d -sw"
                            fg: "#f9e2af"

                            PolledText {
                                id: notificationState
                                interval: 2000
                                fallback: ""
                                command: ["sh", "-lc", "swaync-client -swb 2>/dev/null | python3 -c 'import sys,json; s=sys.stdin.read().strip(); print(json.loads(s).get(\"text\",\"\") if s else \"\")' 2>/dev/null"]
                            }
                        }

                        ActionChip {
                            id: weatherChip
                            label: weatherState.text
                            fg: "#89b4fa"

                            PolledText {
                                id: weatherState
                                interval: 3600000
                                fallback: "--"
                                command: ["sh", "-lc", "wttrbar --date-format '%m/%d' --location Genova --hide-conditions 2>/dev/null | python3 -c 'import sys,json; s=sys.stdin.read().strip(); print((json.loads(s).get(\"text\",\"--\")).replace(\"°\",\"\") if s else \"--\")' 2>/dev/null"]
                            }
                        }

                        PwObjectTracker {
                            objects: [Pipewire.defaultAudioSink]
                        }

                        Rectangle {
                            radius: 11
                            color: "#20263a"
                            border.width: 1
                            border.color: "#4f5d84"
                            implicitHeight: 26
                            implicitWidth: audioLabel.implicitWidth + 16

                            Text {
                                id: audioLabel
                                anchors.centerIn: parent
                                text: {
                                    const sink = Pipewire.defaultAudioSink;
                                    if (sink == null || sink.audio == null) return "A --";
                                    if (sink.audio.muted) return "A mute";
                                    return `A ${Math.round(sink.audio.volume * 100)}%`;
                                }
                                color: "#a6e3a1"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["sh", "-lc", "pavucontrol"])
                            }
                        }

                        ActionChip {
                            id: btChip
                            label: btState.text
                            leftCommand: "blueman-manager"
                            fg: "#89b4fa"

                            PolledText {
                                id: btState
                                interval: 30000
                                fallback: ""
                                command: ["sh", "-lc", "if ! command -v bluetoothctl >/dev/null 2>&1; then echo ''; elif bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then if bluetoothctl devices Connected 2>/dev/null | grep -q .; then echo ' |'; else echo ''; fi; else echo ''; fi"]
                            }
                        }

                        ActionChip {
                            id: netChip
                            label: netState.text
                            leftCommand: "konsole -e nmtui"
                            rightCommand: "nm-connection-editor"
                            fg: "#89b4fa"

                            PolledText {
                                id: netState
                                interval: 5000
                                fallback: "󰌙"
                                command: ["sh", "-lc", "if nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep -q ':wifi:connected'; then echo ' |'; elif nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep -q ':ethernet:connected'; then echo '󰌘 |'; else echo '󰌙'; fi"]
                            }
                        }

                        ActionChip {
                            id: batteryChip
                            label: batteryState.text
                            fg: "#a6e3a1"

                            PolledText {
                                id: batteryState
                                interval: 15000
                                fallback: ""
                                command: ["sh", "-lc", "b=$(upower -e 2>/dev/null | grep -m1 BAT); if [ -z \"$b\" ]; then echo ''; else p=$(upower -i \"$b\" | awk '/percentage/ {gsub(/%/,\"\",$2); print $2; exit}'); st=$(upower -i \"$b\" | awk -F': ' '/state/ {print $2; exit}'); [ -z \"$p\" ] && p='--'; if [ \"$st\" = 'charging' ]; then echo \"$p% 󰂄\"; else echo \"$p%\"; fi; fi"]
                            }
                        }

                        ActionChip {
                            id: langChip
                            label: langState.text
                            leftCommand: "hyprctl switchxkblayout current next"
                            fg: "#89b4fa"

                            PolledText {
                                id: langState
                                interval: 2000
                                fallback: "EN"
                                command: ["sh", "-lc", "k=$(hyprctl devices 2>/dev/null | awk -F': ' '/active keymap/ {print tolower($2); exit}'); case \"$k\" in *arabic*|*ara*) echo 'AR';; *english*|*us*) echo 'EN';; *) if [ -n \"$k\" ]; then echo \"$k\" | tr '[:lower:]' '[:upper:]'; else echo 'EN'; fi;; esac"]
                            }
                        }

                        ActionChip {
                            id: updatesChip
                            label: " " + updatesState.text
                            leftCommand: "konsole -e ~/.config/waybar/scripts/install-updates.sh"
                            fg: "#a6e3a1"

                            PolledText {
                                id: updatesState
                                interval: 60000
                                fallback: "0"
                                command: ["sh", "-lc", "~/.config/waybar/scripts/updates.sh | python3 -c 'import sys,json; s=sys.stdin.read().strip(); print(json.loads(s).get(\"text\",\"0\") if s else \"0\")' 2>/dev/null"]
                            }
                        }

                        Rectangle {
                            id: clockChip
                            radius: 11
                            color: "#22263f"
                            border.width: 1
                            border.color: "#6c77a8"
                            implicitHeight: 26
                            implicitWidth: clockText.implicitWidth + 18

                            property date now: new Date()

                            Timer {
                                running: true
                                repeat: true
                                interval: 1000
                                onTriggered: clockChip.now = new Date()
                            }

                            Text {
                                id: clockText
                                anchors.centerIn: parent
                                text: {
                                    const d = clockChip.now;
                                    const hh = d.getHours().toString().padStart(2, "0");
                                    const mm = d.getMinutes().toString().padStart(2, "0");
                                    return `${hh}:${mm}`;
                                }
                                color: "#f9e2af"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: "#4c566a"
                            opacity: 0.65
                        }

                        ActionChip {
                            id: brightChip
                            label: brightState.text
                            fg: "#f9e2af"

                            PolledText {
                                id: brightState
                                interval: 5000
                                fallback: ""
                                command: ["sh", "-lc", "if command -v brightnessctl >/dev/null 2>&1; then c=$(brightnessctl g 2>/dev/null); m=$(brightnessctl m 2>/dev/null); if [ -n \"$c\" ] && [ -n \"$m\" ] && [ \"$m\" -gt 0 ]; then echo \"$((c*100/m))%\"; fi; fi"]
                            }
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "pkill -SIGUSR1 hypridle"
                            fg: "#f9e2af"
                        }

                        ActionChip {
                            label: "󰄀"
                            leftCommand: "hyprshot -m region"
                            rightCommand: "hyprshot -m output"
                            fg: "#a6e3a1"
                        }

                        ActionChip {
                            label: ""
                            leftCommand: "hyprlock"
                            fg: "#f38ba8"
                        }

                        ActionChip {
                            label: "󰍃"
                            leftCommand: "wlogout"
                            fg: "#f38ba8"
                        }
                    }
                }
            }
        }
    }
}
