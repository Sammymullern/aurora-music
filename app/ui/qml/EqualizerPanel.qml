import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Popup {
    id: panel

    property Item anchorItem
    property var targetWindow

    parent: Overlay.overlay
    x: 12
    y: 12
    width: 820
    height: 640
    padding: 18
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function reposition() {
        const overlay = Overlay.overlay
        if (!overlay || !anchorItem) return

        const margin = 12
        const anchorBottomRight = anchorItem.mapToItem(overlay, anchorItem.width, anchorItem.height)
        const availableWidth = Math.max(320, overlay.width - margin * 2)
        const availableBelow = Math.max(280, overlay.height - anchorBottomRight.y - 8 - margin)

        width = Math.min(820, availableWidth)
        height = Math.min(640, availableBelow)
        x = Math.max(margin, Math.min(anchorBottomRight.x - width, overlay.width - width - margin))
        y = Math.max(margin, Math.min(anchorBottomRight.y + 8, overlay.height - height - margin))
    }

    onOpened: Qt.callLater(reposition)

    function resetAll() {
        equalizer.apply_preset_name("flat")
        equalizer.preamp = 0
        effects.bassEnabled = false
        effects.trebleEnabled = false
        effects.vocalEnabled = false
        effects.stereoEnabled = false
        effects.spatialEnabled = false
    }

    background: Rectangle {
        radius: 18
        color: theme.backgroundDark
        border.color: theme.border
        border.width: 1

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            radius: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#22d3ee" }
                GradientStop { position: 0.55; color: theme.primary }
                GradientStop { position: 1.0; color: "#c084fc" }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Label {
                    text: "Audio Equalizer"
                    color: theme.textPrimary
                    font.pixelSize: 20
                    font.bold: true
                }
                Label {
                    text: "Fine-tune your listening experience"
                    color: theme.textSecondary
                    font.pixelSize: 11
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                text: equalizer.enabled ? "ON" : "BYPASSED"
                color: equalizer.enabled ? "#67e8c0" : theme.textSecondary
                font.pixelSize: 10
                font.bold: true
            }
            Switch {
                checked: equalizer.enabled
                onToggled: equalizer.enabled = checked
            }
            Button {
                text: "Reset"
                flat: true
                onClicked: panel.resetAll()
            }
            ToolButton {
                text: "×"
                ToolTip.text: "Close equalizer"
                ToolTip.visible: hovered
                onClicked: panel.close()
            }
        }

        ScrollView {
            id: body
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: body.availableWidth
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: theme.border
                    opacity: 0.65
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "PRESETS"
                        color: theme.textSecondary
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.4
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: equalizer.currentPreset === "custom" ? "CUSTOM" : equalizer.currentPreset.replace("_", " ").toUpperCase()
                        color: theme.primaryLight
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Button {
                        text: "Save preset"
                        flat: true
                        onClicked: {
                            saveName.text = equalizer.currentPreset === "custom" ? "" : equalizer.currentPreset.replace("_", " ")
                            saveDialog.open()
                        }
                    }
                    Button {
                        text: "Delete"
                        flat: true
                        enabled: effects.customPresets.indexOf(equalizer.currentPreset) >= 0
                        onClicked: effects.delete_custom_preset(equalizer.currentPreset)
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    spacing: 7

                    Repeater {
                        model: [
                            { label: "Flat", key: "flat" },
                            { label: "Rock", key: "rock" },
                            { label: "Pop", key: "pop" },
                            { label: "Jazz", key: "jazz" },
                            { label: "Classical", key: "classical" },
                            { label: "Hip-Hop", key: "hip_hop" },
                            { label: "Electronic", key: "electronic" },
                            { label: "Acoustic", key: "acoustic" },
                            { label: "Vocal", key: "vocal" },
                            { label: "Bass Boost", key: "bass_boost" },
                            { label: "Deep Bass", key: "deep_bass" },
                            { label: "Treble Boost", key: "treble_boost" },
                            { label: "Podcast", key: "podcast" }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            width: 112
                            height: 30
                            radius: 9
                            color: equalizer.currentPreset === modelData.key ? theme.primary : theme.surface
                            border.color: equalizer.currentPreset === modelData.key ? theme.primaryLight : theme.border

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: theme.textPrimary
                                font.pixelSize: 10
                                font.bold: equalizer.currentPreset === modelData.key
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: equalizer.apply_preset_name(modelData.key)
                            }
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: effects.customPresets.length > 0 ? 34 : 0
                    spacing: 7
                    Repeater {
                        model: effects.customPresets
                        delegate: Rectangle {
                            required property string modelData
                            width: Math.max(96, Math.min(170, label.implicitWidth + 24))
                            height: 30
                            radius: 9
                            color: equalizer.currentPreset === modelData ? "#34345c" : theme.surface
                            border.color: equalizer.currentPreset === modelData ? theme.primaryLight : theme.border
                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: theme.textPrimary
                                font.pixelSize: 10
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: effects.apply_custom_preset(parent.modelData)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: theme.border
                    opacity: 0.65
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "10-BAND GRAPHIC EQ"
                        color: theme.textSecondary
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                    }
                    Item { Layout.fillWidth: true }
                    Label { text: "+12 dB     0 dB     −12 dB"; color: theme.textSecondary; font.pixelSize: 9 }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    spacing: 4

                    Repeater {
                        model: 10
                        delegate: ColumnLayout {
                            id: bandColumn
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 5

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: (equalizer.bands[bandColumn.index] > 0 ? "+" : "") + Number(equalizer.bands[bandColumn.index]).toFixed(1)
                                color: equalizer.bands[bandColumn.index] > 0 ? "#67e8c0" : (equalizer.bands[bandColumn.index] < 0 ? "#c4a7ff" : theme.textSecondary)
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Slider {
                                id: bandSlider
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillHeight: true
                                Layout.preferredWidth: 30
                                Layout.minimumHeight: 136
                                orientation: Qt.Vertical
                                from: -12
                                to: 12
                                stepSize: 0.1
                                value: equalizer.bands[bandColumn.index]
                                enabled: equalizer.enabled
                                onMoved: equalizer.set_band_gain(bandColumn.index, value)

                                background: Item {
                                    x: bandSlider.leftPadding + (bandSlider.availableWidth - width) / 2
                                    y: bandSlider.topPadding
                                    width: 4
                                    height: bandSlider.availableHeight

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 2
                                        color: theme.surfaceVariant
                                    }
                                    Rectangle {
                                        id: gainFill
                                        readonly property real centerY: parent.height / 2
                                        readonly property real valueY: parent.height * (1 - (bandSlider.value - bandSlider.from) / (bandSlider.to - bandSlider.from))
                                        y: Math.min(centerY, valueY)
                                        height: Math.max(2, Math.abs(valueY - centerY))
                                        width: parent.width
                                        radius: 2
                                        color: bandSlider.value >= 0 ? "#38d9bd" : "#a78bfa"
                                        opacity: bandSlider.enabled ? 1 : 0.35
                                    }
                                    Rectangle {
                                        x: -4
                                        y: parent.height / 2 - height / 2
                                        width: 12
                                        height: 2
                                        radius: 1
                                        color: theme.textSecondary
                                    }
                                }

                                handle: Rectangle {
                                    x: bandSlider.leftPadding + (bandSlider.availableWidth - width) / 2
                                    y: bandSlider.topPadding + (1 - (bandSlider.value - bandSlider.from) / (bandSlider.to - bandSlider.from)) * (bandSlider.availableHeight - height)
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: bandSlider.enabled ? theme.textPrimary : theme.textDisabled
                                    border.width: 3
                                    border.color: bandSlider.enabled ? (bandSlider.value >= 0 ? "#38d9bd" : "#a78bfa") : theme.border
                                }
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: ["31", "62", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"][bandColumn.index]
                                color: theme.textPrimary
                                font.pixelSize: 9
                                font.bold: true
                            }
                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Hz"
                                color: theme.textDisabled
                                font.pixelSize: 8
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Label {
                        text: "PREAMP"
                        color: theme.textSecondary
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                    }
                    Label {
                        text: (equalizer.preamp > 0 ? "+" : "") + Number(equalizer.preamp).toFixed(1) + " dB"
                        color: theme.primaryLight
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Slider {
                        id: preampSlider
                        Layout.fillWidth: true
                        from: -12
                        to: 12
                        stepSize: 0.1
                        value: equalizer.preamp
                        enabled: equalizer.enabled
                        onMoved: equalizer.preamp = value
                    }
                    Button {
                        text: "0 dB"
                        flat: true
                        onClicked: equalizer.preamp = 0
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: theme.border
                    opacity: 0.65
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "AUDIO ENHANCEMENTS"
                        color: theme.textSecondary
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: "Limiter protects boosted audio from clipping"
                        color: theme.textDisabled
                        font.pixelSize: 9
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: panel.width < 600 ? 1 : 2
                    rowSpacing: 9
                    columnSpacing: 9

                    Repeater {
                        model: [
                            { title: "Bass enhancement", detail: "Controlled low-frequency lift", key: "bass", max: 8, suffix: " dB" },
                            { title: "Treble enhancement", detail: "Gentle high-frequency lift", key: "treble", max: 6, suffix: " dB" },
                            { title: "Vocal presence", detail: "Clarity around the vocal range", key: "vocal", max: 6, suffix: " dB" },
                            { title: "Stereo widening", detail: "Preserves the center for mono playback", key: "stereo", max: 150, suffix: "%" },
                            { title: "Spatial audio", detail: "Headphone spatializer (FFmpeg earwax)", key: "spatial", max: 0, suffix: "" }
                        ]

                        delegate: Rectangle {
                            id: effectCard
                            required property var modelData
                            property bool effectActive: modelData.key === "bass" ? effects.bassEnabled :
                                modelData.key === "treble" ? effects.trebleEnabled :
                                modelData.key === "vocal" ? effects.vocalEnabled :
                                modelData.key === "stereo" ? effects.stereoEnabled : effects.spatialEnabled
                            property real effectAmount: modelData.key === "bass" ? effects.bassIntensity :
                                modelData.key === "treble" ? effects.trebleIntensity :
                                modelData.key === "vocal" ? effects.vocalIntensity : effects.stereoWidth
                            Layout.fillWidth: true
                            Layout.preferredHeight: modelData.key === "spatial" ? 83 : 118
                            radius: 12
                            color: theme.surface
                            border.color: effectActive ? theme.borderLight : theme.border

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 11
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        spacing: 2
                                        Label {
                                            text: effectCard.modelData.title
                                            color: theme.textPrimary
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Label {
                                            text: effectCard.modelData.detail
                                            color: theme.textDisabled
                                            font.pixelSize: 9
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Switch {
                                        checked: effectCard.effectActive
                                        onToggled: {
                                            if (effectCard.modelData.key === "bass") effects.bassEnabled = checked
                                            else if (effectCard.modelData.key === "treble") effects.trebleEnabled = checked
                                            else if (effectCard.modelData.key === "vocal") effects.vocalEnabled = checked
                                            else if (effectCard.modelData.key === "stereo") effects.stereoEnabled = checked
                                            else effects.spatialEnabled = checked
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: effectCard.modelData.key !== "spatial"
                                    Slider {
                                        Layout.fillWidth: true
                                        from: effectCard.modelData.key === "stereo" ? 100 : 0
                                        to: effectCard.modelData.max
                                        stepSize: effectCard.modelData.key === "stereo" ? 1 : 0.1
                                        value: effectCard.effectAmount
                                        enabled: effectCard.effectActive
                                        onMoved: {
                                            if (effectCard.modelData.key === "bass") effects.bassIntensity = value
                                            else if (effectCard.modelData.key === "treble") effects.trebleIntensity = value
                                            else if (effectCard.modelData.key === "vocal") effects.vocalIntensity = value
                                            else effects.stereoWidth = value
                                        }
                                    }
                                    Label {
                                        text: (effectCard.modelData.key === "stereo" ? Number(effectCard.effectAmount).toFixed(0) : Number(effectCard.effectAmount).toFixed(1)) + effectCard.modelData.suffix
                                        color: effectCard.effectActive ? theme.primaryLight : theme.textDisabled
                                        font.pixelSize: 9
                                        Layout.preferredWidth: 42
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: player.dspStatus
                    color: player.dspStatus.indexOf("could not") >= 0 || player.dspStatus.indexOf("rejected") >= 0 ? "#fca5a5" : theme.textDisabled
                    font.pixelSize: 9
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Dialog {
        id: saveDialog
        parent: Overlay.overlay
        x: panel.x + (panel.width - width) / 2
        y: panel.y + 92
        width: 320
        modal: true
        title: "Save custom preset"
        standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: {
            if (effects.save_custom_preset(saveName.text)) close()
        }

        contentItem: ColumnLayout {
            spacing: 8
            Label {
                text: "Enter a name. Saving an existing name overwrites it."
                color: theme.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            TextField {
                id: saveName
                Layout.fillWidth: true
                maximumLength: 32
                placeholderText: "My preset"
                onAccepted: saveDialog.accept()
            }
        }
    }
}
