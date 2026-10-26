#!/usr/bin/env python3
"""Resolve the display name saved by Omarchy setup."""
import os
import pwd
import subprocess

name = os.environ.get('OMARCHY_USER_NAME', '').strip()
if not name:
    try:
        name = subprocess.check_output(
            ['git', 'config', '--global', '--get', 'user.name'],
            text=True, stderr=subprocess.DEVNULL, timeout=3,
        ).strip()
    except (OSError, subprocess.SubprocessError):
        pass
if not name:
    name = pwd.getpwuid(os.getuid()).pw_gecos.split(',')[0].strip()
print(name or 'Choom')
