import QtQuick
import QtQuick.Layouts
import "Quotes.js" as Quotes
import "Links.js" as Links
import "WeatherSettings.js" as WeatherSettings
import Quickshell
import Quickshell.Io

Item {
    id: desktop
    property var now: new Date()
    property color neon: settings.accent || "#f3ec35"
    property color cyan: "#56e5ed"
    property var settings: ({})
    property var shellSettings: ({})
    readonly property int weatherRefreshMinutes: WeatherSettings.refreshMinutes(settings.weatherRefreshMinutes, shellSettings)
    property string weather: "Weather unavailable"
    property string systemName: "Choom"
    readonly property string userName: settings.name || systemName
    readonly property string datePattern: settings.dateFormat || Qt.locale().dateFormat(Locale.LongFormat)
    readonly property string timePattern: settings.timeFormat || (typeof settings.clock24 === "boolean" ? (settings.clock24 ? "HH:mm" : "hh:mm AP") : Qt.locale().timeFormat(Locale.ShortFormat))
    readonly property var links: settings.links || []
    readonly property var linkGroups: Links.group(links)
    readonly property var quotes: Quotes.resolve(settings.quotes)
    readonly property string quote: Quotes.forDay(quotes, now)
    Timer { interval: 1000; running: true; repeat: true; onTriggered: desktop.now = new Date() }
    FileView {
        id: preferences
        path: Quickshell.env("HOME") + "/.config/omarchy/plugins/priceja.background/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                desktop.settings = JSON.parse(text())
                weatherProcess.running = false
                weatherProcess.running = true
            }
            catch (error) { console.warn("Cyber Desktop settings:", error) }
        }
    }
    Process {
        id: identityProcess
        command: ["python3", Quickshell.env("HOME") + "/.config/omarchy/plugins/priceja.background/identity.py"]
        running: true
        stdout: StdioCollector { onStreamFinished: desktop.systemName = text.trim() || "Choom" }
    }
    FileView {
        path: Quickshell.env("HOME") + "/.local/state/omarchy/settings/weather.json"
        watchChanges: true
        printErrors: false
        onFileChanged: {
            reload()
            weatherProcess.running = false
            weatherProcess.running = true
        }
    }
    FileView {
        path: Quickshell.env("HOME") + "/.config/omarchy/shell.json"
        watchChanges: true
        printErrors: false
        onLoaded: {
            try { desktop.shellSettings = JSON.parse(text()) }
            catch (error) { console.warn("Cyber Desktop shell settings:", error) }
        }
        onFileChanged: {
            reload()
            weatherProcess.running = false
            weatherProcess.running = true
        }
    }
    Process {
        id: weatherProcess
        command: ["python3", Quickshell.env("HOME") + "/.config/omarchy/plugins/priceja.background/weather.py", Qt.locale().name]
        stdout: StdioCollector { onStreamFinished: desktop.weather = text.trim() || "Weather unavailable" }
    }
    Timer { interval: desktop.weatherRefreshMinutes * 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!weatherProcess.running) weatherProcess.running = true }
    Rectangle { anchors.fill: parent; color: "#bf090e19" }
    Repeater {
        model: 16
        Rectangle { required property int index; x: parent.width * index / 16; width: 1; height: parent.height; color: "#0b56e5ed" }
    }
    Rectangle { x: 0; y: 72; width: parent.width; height: 2; color: desktop.neon; opacity: 0.5 }
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 1040)
        spacing: 20
        Text { text: "NIGHT CITY // PERSONAL TERMINAL"; color: desktop.cyan; font.family: "monospace"; font.pixelSize: 14; font.letterSpacing: 3 }
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Text { text: Qt.formatDateTime(desktop.now, desktop.timePattern); color: desktop.neon; font.family: "monospace"; font.bold: true; font.pixelSize: Math.min(100, desktop.width / 10) }
                Text { text: Qt.locale().toString(desktop.now, desktop.datePattern); color: desktop.cyan; font.family: "monospace"; font.pixelSize: 16 }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                Layout.maximumWidth: 350
                Text { text: "WELCOME BACK, " + desktop.userName.toUpperCase(); color: desktop.neon; font.family: "monospace"; font.pixelSize: 18; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Text { text: desktop.weather; color: "#d4e0e8"; font.family: "monospace"; font.pixelSize: 14; wrapMode: Text.Wrap; Layout.fillWidth: true }
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 2; color: desktop.neon }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 58; color: "#dd101c2b"; border.color: search.activeFocus ? desktop.neon : desktop.cyan
            RowLayout {
                anchors.fill: parent; anchors.margins: 14; spacing: 16
                Text { text: ">_"; color: desktop.neon; font.family: "monospace"; font.pixelSize: 20 }
                TextInput {
                    id: search
                    Layout.fillWidth: true; color: "#eef7ff"; font.family: "monospace"; font.pixelSize: 17
                    clip: true; selectByMouse: true
                    Text { anchors.fill: parent; visible: !search.text && !search.activeFocus; text: "SEARCH THE NET…"; color: "#7f97a9"; font: search.font }
                    onAccepted: {
                        if (!text.trim()) return
                        const engines = { DuckDuckGo: "https://duckduckgo.com/?q=", Google: "https://www.google.com/search?q=", Bing: "https://www.bing.com/search?q=" }
                        Qt.openUrlExternally((engines[desktop.settings.searchEngine] || engines.DuckDuckGo) + encodeURIComponent(text.trim()))
                        text = ""; focus = false
                    }
                    Keys.onEscapePressed: { text = ""; focus = false }
                }
            }
        }
        Text { text: "NETLINKS // QUICK ACCESS"; color: desktop.cyan; font.family: "monospace"; font.pixelSize: 13; font.letterSpacing: 2 }
        Flow {
            id: categoryFlow
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            spacing: 20
            Repeater {
                model: desktop.linkGroups
                Column {
                    id: categoryGroup
                    required property var modelData
                    width: Math.min(245, categoryFlow.width)
                    spacing: 10
                    Text {
                        text: categoryGroup.modelData.name
                        color: desktop.cyan; font.family: "monospace"
                        font.pixelSize: 12; font.letterSpacing: 2
                    }
                    Rectangle { width: parent.width; height: 1; color: desktop.cyan; opacity: 0.65 }
                    Repeater {
                        model: categoryGroup.modelData.links
                        Rectangle {
                            id: linkCard
                            required property var modelData
                            width: categoryGroup.width; height: 58
                            color: linkMouse.containsMouse ? "#ee263746" : "#dd101c2b"
                            border.color: linkMouse.containsMouse ? desktop.neon : "#37576a"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 14; spacing: 12
                                Image {
                                    Layout.preferredWidth: 24; Layout.preferredHeight: 24
                                    source: "icons/" + Links.icon(linkCard.modelData) + ".svg"
                                    sourceSize.width: 24; sourceSize.height: 24
                                }
                                Text {
                                    text: linkCard.modelData.name
                                    color: desktop.neon; font.family: "monospace"; font.pixelSize: 16
                                    Layout.fillWidth: true; elide: Text.ElideRight
                                }
                            }
                            MouseArea {
                                id: linkMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (/^https?:\/\//.test(linkCard.modelData.url)) Qt.openUrlExternally(linkCard.modelData.url)
                            }
                        }
                    }
                }
            }
        }
        Text { text: desktop.quote; color: "#a4b8c7"; font.family: "monospace"; font.pixelSize: 14; wrapMode: Text.Wrap; Layout.fillWidth: true }
        Text { text: "SYSTEM ONLINE  /  ESC TO CLEAR SEARCH"; color: desktop.cyan; font.family: "monospace"; font.pixelSize: 11; opacity: 0.65 }
    }
}
