.pragma library

// Original cyberpunk-style lines, not dialogue or excerpts from licensed works.
var defaults = [
    "The skyline belongs to the corps. The alley still knows your name.",
    "Chrome can replace a hand. It cannot decide who you reach for.",
    "Keep one dream the city cannot put a price on.",
    "Every camera has an owner. Every shadow has a story.",
    "The moon looks close when the streets won't let you breathe.",
    "A clean signal is rare. A friend who answers is rarer.",
    "They sold you an upgrade. Read what it costs to stay yourself.",
    "Some debts are counted in eddies. The worst are counted in names.",
    "The city remembers your mistakes longer than your victories.",
    "Neon makes a fine promise and a lousy sunrise.",
    "Your backup is only as good as the choom holding it.",
    "When everything is connected, solitude becomes contraband.",
    "A corporate badge opens doors. It never tells you who locked them.",
    "Even a borrowed body can carry a stubborn heart.",
    "Don't confuse a full wallet with a way out.",
    "The contract covers extraction. Getting home is something else.",
    "In a city that records everything, kindness leaves the strangest trace.",
    "Someone is charging rent on the future. Build a door they missed.",
    "Rain washes the pavement. It leaves the deals untouched.",
    "Leave a little room beneath the armour for the person you came here to be.",
    "The loudest advertisement is always selling something you already lost.",
    "A legend is a person the city stopped letting be ordinary.",
    "There are exits the map won't show you. Bring someone worth leaving with.",
    "The lights stay on because someone below the skyline keeps working.",
    "You can encrypt a message. Trust still travels in the clear.",
    "Not every ghost in the machine wants to be restored.",
    "A perfect memory can still tell you the wrong story.",
    "Choose your crew before the city chooses your price.",
    "The network can find your location. It cannot tell you where you belong.",
    "Some nights, surviving is the only rebellion you have left.",
    "Tomorrow isn't in the contract. Make plans anyway."
]

function resolve(override) {
    // Recognize the original bundled placeholders without replacing custom lists.
    var legacy = ["The city is yours. Make something worth keeping.", "Stay curious. Keep building.", "Another day. Another possibility."]
    if (override === undefined || override === null || JSON.stringify(override) === JSON.stringify(legacy)) return defaults
    return Array.isArray(override) ? override : defaults
}

function forDay(quotes, date) {
    return quotes.length ? quotes[(date.getDate() - 1) % quotes.length] : ""
}
