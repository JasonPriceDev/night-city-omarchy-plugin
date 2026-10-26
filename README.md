# Cyber Desktop

Native Quickshell desktop dashboard, inspired by the Cyberpunk homepage.
No extension code or artwork is bundled. Daily quotes are original cyberpunk-style
lines; see [QUOTES.md](QUOTES.md) for research references and selection details.

Plugin source and bundled assets live in `src/`; tests live in `tests/`.
Run the weather tests from the repository root with:

```bash
PYTHONPATH=src python3 -m unittest discover -s tests -v
```

The repository lives in `~/code/night-city-omarchy-plugin`.
Omarchy loads a separate installed copy at
`~/.config/omarchy/plugins/priceja.background`. Source edits do not change
the desktop until you explicitly install them.

After reviewing your changes, deploy manually:

```bash
cd ~/code/night-city-omarchy-plugin
./install.sh
```

The installer backs up the existing plugin under
`~/.local/state/omarchy/backups/night-city-backup-*` and preserves installed
settings. It does not enable the plugin or restart the shell. Omarchy may
hot-reload the copied files during installation.

Create a manual backup, list snapshots, or restore a selected snapshot:

```bash
./backup.sh
./backup.sh --list
./revert.sh ~/.local/state/omarchy/backups/night-city-backup-TIMESTAMP.ID
```

Backups include the complete installed plugin and its settings. Revert replaces
the installation with the selected snapshot, removing files added since that
snapshot, and first creates a safety backup of the current installation.
A snapshot from before first installation restores the absence of the plugin.
Source files and shell enablement are unchanged; reverting does not restore
unrelated desktop settings. Restart the shell if it does not reload automatically.
Use only trusted local snapshots. The original full desktop backup is described
below, separately from these plugin-only snapshots.

Configuration: `src/settings.json` provides defaults for first installation.
To change your live preferences, edit the installed settings.json explicitly;
those changes reload automatically. Updating source settings does not overwrite
your installed preferences.

Omit a key or set it to null to use the system default:

| Setting | System default | Example override |
|---|---|---|
| name | Omarchy setup name: OMARCHY_USER_NAME, global Git user.name, account full name, then Choom | "Jason" |
| dateFormat | OS locale long date pattern | "yyyy-MM-dd" |
| timeFormat | OS locale short time pattern | "HH:mm" |
| clock24 | OS locale; timeFormat takes precedence | true or false |
| weatherLocation | Omarchy saved coordinates/name, otherwise IP detection | "Toronto" |
| temperatureUnit | Omarchy weather unit override, then report country, then OS locale | "C" or "F" |
| weatherRefreshMinutes | Omarchy weather widget's refreshMinutes, otherwise its 15-minute default | 5 |

Date/time patterns use Qt syntax. Restart the shell after changing the session
locale to pick up the new environment. Settings changes reload automatically.
Existing explicit settings are preserved during installation: reset older name,
clock24, or weatherLocation overrides to null to follow the OS.

Weather follows ~/.local/state/omarchy/settings/weather.json; change the shared
location in Omarchy's weather panel or with `omarchy-weather-location --set "City"`.
`--clear` restores IP detection. Requests go to wttr.in at the configured interval and on
location/settings changes. Cached results use the currently selected unit.
The refresh interval has a one-minute minimum, matching Omarchy. Omitting
weatherRefreshMinutes or setting it to null follows the widget; changes to
either configuration update the timer automatically.

Other plugin preferences:
- accent: colour in hex
- searchEngine: DuckDuckGo, Google, or Bing (no shared OS search-engine preference)
- links: name, category, and HTTPS URL per entry. Links sharing a category appear
  together below an underlined heading, in their configured order. Category names
  are case-insensitive. Icons are selected automatically by site or category;
  set icon to github, gitlab, book, play, terminal, or globe to override.
- quotes: null uses the 31 bundled cyberpunk-style lines; an array overrides them,
  and [] hides them. Selection stays constant for each local calendar day and
  repeats monthly. Original bundled placeholders automatically use the new bank.

Click the search field and press Enter to search in your default browser.
Escape clears search. Links open in your default browser.
The dashboard is shown on the first screen reported by Quickshell.
The original wallpaper remains underneath the tint and grid.
Wallpaper/theme double-click gestures remain available on empty desktop areas.
Keyboard focus uses OnDemand; compositor focus behaviour needs live verification.
Video wallpaper and an in-dashboard settings editor are not included.

To restore the built-in background:
    omarchy plugin disable priceja.background
    omarchy plugin enable omarchy.background

Complete original configuration backup:
~/.local/state/omarchy/backups/cyberdesktop-20261026-114258/

To restore the original shell configuration exactly:
    cp ~/.local/state/omarchy/backups/cyberdesktop-20261026-114258/omarchy/shell.json ~/.config/omarchy/shell.json

If the shell has not picked up the plugin:
    omarchy-shell shell rescanPlugins
    omarchy restart shell
