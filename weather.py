#!/usr/bin/env python3
"""Follow Omarchy's saved weather location, including IP auto-detection."""
import json
import math
import pathlib
import locale
import re
import sys
import urllib.parse
import urllib.request


def location_query(state):
    latitude, longitude = state.get('latitude'), state.get('longitude')
    if (type(latitude) in (int, float) and type(longitude) in (int, float)
            and math.isfinite(latitude) and math.isfinite(longitude)
            and -90 <= latitude <= 90 and -180 <= longitude <= 180):
        return f'{latitude},{longitude}'
    return str(state.get('name') or '')


def omarchy_unit(home):
    """Read the same inline weather entry used by Omarchy's panel."""
    try:
        shell = json.loads((home / '.config/omarchy/shell.json').read_text())
        layout = shell.get('bar', {}).get('layout', {})
        entries = [entry for section in ('left', 'center', 'right')
                   for entry in layout.get(section, [])]
        entries += shell.get('plugins', [])
        for entry in entries:
            if isinstance(entry, dict) and entry.get('id') == 'omarchy.weather':
                return str(entry.get('unit') or '').strip().lower()
    except (OSError, ValueError):
        pass
    return ''


def temperature_unit(settings, data=None, unit_override='', locale_name=''):
    override = settings.get('temperatureUnit')
    if override in ('C', 'F'):
        return override
    if unit_override in ('imperial', 'metric'):
        return 'F' if unit_override == 'imperial' else 'C'
    area = ((data or {}).get('nearest_area') or [{}])[0]
    country = str((area.get('country') or [{}])[0].get('value') or '')
    country = re.sub(r'[._-]+', ' ', country.strip()).lower()
    if country:
        return 'F' if country in ('us', 'usa', 'united states',
                                  'united states of america', 'liberia',
                                  'myanmar', 'burma') else 'C'
    # Match Omarchy Model.js localeUsesImperial when no country is available.
    name = locale_name.replace('.', '_')
    return 'F' if re.match(r'^(en[_-]US($|[_.-])|en[_-]LR($|[_.-])|my($|[_.-]))', name) else 'C'


def format_report(data, state, unit):
    current = data['current_condition'][0]
    nearest = data.get('nearest_area') or [{}]
    area = nearest[0].get('areaName') or [{'value': 'Local weather'}]
    label = state.get('name') or area[0]['value']
    return f"{label} · {current['temp_' + unit]}°{unit} · {current['weatherDesc'][0]['value']}"


def main():
    home = pathlib.Path.home()
    cache = home / '.cache/cyberdesktop/weather.json'
    saved = home / '.local/state/omarchy/settings/weather.json'
    state = {}
    query = ''
    unit = 'C'
    settings = {}
    shared_unit = omarchy_unit(home)
    try:
        locale.setlocale(locale.LC_ALL, '')
    except locale.Error:
        pass
    locale_name = sys.argv[1] if len(sys.argv) > 1 else (locale.getlocale()[0] or '')
    try:
        settings = json.loads(pathlib.Path(__file__).with_name('settings.json').read_text())
        unit = temperature_unit(settings, unit_override=shared_unit, locale_name=locale_name)
        if saved.exists():
            state = json.loads(saved.read_text())
        override = settings.get('weatherLocation')
        if isinstance(override, str) and override.strip():
            state = {'name': override.strip()}
        query = location_query(state)
        # Omarchy uses an empty query for IP-based automatic location detection.
        url = 'https://wttr.in/' + urllib.parse.quote(query, safe=',') + '?format=j1'
        with urllib.request.urlopen(url, timeout=8) as response:
            data = json.load(response)
        unit = temperature_unit(settings, data, shared_unit, locale_name)
        report = format_report(data, state, unit)
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps({'query': query, 'data': data}))
        print(report)
    except Exception:
        try:
            previous = json.loads(cache.read_text())
            if previous['query'] != query:
                raise ValueError('Cached weather is for a different location')
            unit = temperature_unit(settings, previous['data'], shared_unit, locale_name)
            print(format_report(previous['data'], state, unit) + ' (cached)')
        except (OSError, ValueError, KeyError):
            print('Weather unavailable · offline')


if __name__ == '__main__':
    main()
