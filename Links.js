// Preserve first-seen category order and link order within each category.
function group(links) {
    var groups = []
    if (!Array.isArray(links)) return groups
    links.forEach(function(link) {
        if (!link || typeof link !== "object") return
        var name = String(link.category || "NETLINK").trim().toUpperCase() || "NETLINK"
        var category = groups.find(function(item) { return item.name === name })
        if (!category) {
            category = { name: name, links: [] }
            groups.push(category)
        }
        category.links.push(link)
    })
    return groups
}

function icon(link) {
    var available = ["github", "gitlab", "book", "play", "terminal", "globe"]
    if (available.indexOf(link.icon) !== -1) return link.icon
    var host = String(link.url || "").replace(/^https?:\/\//i, "").split("/")[0].split(":")[0].toLowerCase()
    if (host === "github.com" || host === "www.github.com") return "github"
    if (host === "gitlab.com" || host === "www.gitlab.com") return "gitlab"
    if (host === "youtube.com" || host.endsWith(".youtube.com") || host === "youtu.be") return "play"
    var category = String(link.category || "").trim().toUpperCase()
    if (category === "REFERENCE") return "book"
    if (category === "SYSTEM" || category === "CODE") return "terminal"
    return "globe"
}
