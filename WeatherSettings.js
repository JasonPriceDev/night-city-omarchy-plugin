.pragma library

function refreshMinutes(override, shell) {
    var value = override
    if (value === undefined || value === null) {
        value = 15 // Omarchy Weather Panel.qml default.
        var layout = shell && shell.bar ? shell.bar.layout || {} : {}
        var entries = [].concat(layout.left || [], layout.center || [], layout.right || [], (shell || {}).plugins || [])
        for (var i = 0; i < entries.length; i++) {
            if (entries[i] && entries[i].id === "omarchy.weather") {
                if (entries[i].refreshMinutes !== undefined && entries[i].refreshMinutes !== null)
                    value = entries[i].refreshMinutes
                break
            }
        }
    }
    // Match Omarchy's parsing and one-minute minimum.
    return Math.max(1, parseInt(value, 10) || 15)
}
