#!/usr/bin/env python3
"""Back up and restore installed plugin snapshots, never project source."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import tempfile

HOME = Path.home()
INSTALLED = HOME / '.config/omarchy/plugins/priceja.background'
BACKUPS = HOME / '.local/state/omarchy/backups'


def check_destination():
    if INSTALLED.is_symlink():
        raise ValueError(f'Refusing to modify a symlink: {INSTALLED}')
    if INSTALLED.exists() and not INSTALLED.is_dir():
        raise ValueError(f'Expected a plugin directory: {INSTALLED}')


def backup():
    check_destination()
    BACKUPS.mkdir(parents=True, exist_ok=True)
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    target = Path(tempfile.mkdtemp(prefix=f'night-city-backup-{stamp}.', dir=BACKUPS))
    if INSTALLED.exists():
        shutil.copytree(INSTALLED, target / 'plugin', symlinks=True)
    (target / 'snapshot.json').write_text(json.dumps({
        'version': 1, 'installed': INSTALLED.exists(),
        'created': datetime.datetime.now().astimezone().isoformat(),
    }, indent=2) + '\n')
    return target


def restore(snapshot):
    snapshot = snapshot.expanduser().resolve()
    metadata = json.loads((snapshot / 'snapshot.json').read_text())
    if metadata.get('version') != 1 or type(metadata.get('installed')) is not bool:
        raise ValueError('Unsupported snapshot metadata')
    plugin = snapshot / 'plugin'
    if metadata['installed']:
        if plugin.is_symlink() or not plugin.is_dir():
            raise ValueError('Snapshot plugin directory is missing or invalid')
        manifest = json.loads((plugin / 'manifest.json').read_text())
        if manifest.get('id') != 'priceja.background':
            raise ValueError('Snapshot is for a different plugin')
        json.loads((plugin / 'settings.json').read_text())
    check_destination()
    safety = backup()
    print(f'Before-revert backup: {safety}')
    INSTALLED.parent.mkdir(parents=True, exist_ok=True)
    # Stage the full snapshot first, so copy failure leaves the install untouched.
    with tempfile.TemporaryDirectory(prefix='.night-city-revert-', dir=INSTALLED.parent) as temporary:
        stage = Path(temporary) / 'plugin'
        if metadata['installed']:
            shutil.copytree(plugin, stage, symlinks=True)
        previous = Path(temporary) / 'previous'
        if INSTALLED.exists():
            INSTALLED.rename(previous)
        try:
            if metadata['installed']:
                stage.rename(INSTALLED)
        except Exception:
            if previous.exists():
                previous.rename(INSTALLED)
            raise
    print(f'Reverted installed plugin to: {snapshot}')
    print('Shell enablement and project source were not changed.')
    print('If needed, run: omarchy-shell shell rescanPlugins')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['backup', 'list', 'revert'])
    parser.add_argument('snapshot', nargs='?', type=Path)
    args = parser.parse_args()
    if args.action == 'backup':
        print(backup())
    elif args.action == 'list':
        for item in sorted(BACKUPS.glob('night-city-backup-*')):
            if (item / 'snapshot.json').is_file():
                print(item)
    elif args.snapshot is None:
        parser.error('revert requires an explicit snapshot directory; use list to find one')
    else:
        restore(args.snapshot)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as error:
        raise SystemExit(f'Error: {error}')
