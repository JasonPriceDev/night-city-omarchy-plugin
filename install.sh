#!/usr/bin/env bash
# Manually deploy a snapshot; preserve the installed user's settings.
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_dir="$project_dir/src"
destination="$HOME/.config/omarchy/plugins/priceja.background"
backup_root="$HOME/.local/state/omarchy/backups"

if [[ -L $destination ]]; then
  echo "Refusing to install over a symlink: $destination" >&2
  exit 1
fi
python3 -m json.tool "$source_dir/manifest.json" >/dev/null
python3 -m json.tool "$source_dir/settings.json" >/dev/null
mkdir -p "$(dirname -- "$destination")" "$backup_root"
stage=$(mktemp -d "$(dirname -- "$destination")/.night-city-install.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
for file in Background.qml CyberDesktop.qml manifest.json weather.py identity.py settings.json Quotes.js WeatherSettings.js Links.js; do
  cp -- "$source_dir/$file" "$stage/$file"
done
cp -a -- "$source_dir/icons" "$stage/icons"
if [[ -d $destination ]]; then
  if [[ -f $destination/settings.json ]]; then
    cp -- "$destination/settings.json" "$stage/settings.json"
  fi
  backup=$("$project_dir/backup.sh")
  echo "Backup: $backup"
  # Copy the staged snapshot, retaining a valid plugin directory during updates.
  cp -a -- "$stage/." "$destination/"
else
  backup=$("$project_dir/backup.sh")
  echo "Backup: $backup"
  mv -- "$stage" "$destination"
fi
echo "Installed snapshot: $destination"
echo "Installed settings were preserved. Plugin enablement was not changed."
echo "If needed, run: omarchy-shell shell rescanPlugins"
