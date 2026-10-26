import json
from pathlib import Path
import tempfile
import unittest
from weather import temperature_unit, format_report, omarchy_unit


def report(country):
    return {'nearest_area': [{'country': [{'value': country}]}],
            'current_condition': [{'temp_C': '10', 'temp_F': '50',
                                   'weatherDesc': [{'value': 'Clear'}]}]}


class UnitTests(unittest.TestCase):
    def test_omarchy_priority(self):
        self.assertEqual(temperature_unit({}, report('Canada'), '', 'en_US'), 'C')
        self.assertEqual(temperature_unit({}, report('United States'), '', 'en_CA'), 'F')
        self.assertEqual(temperature_unit({}, report('Canada'), 'imperial', 'en_CA'), 'F')
        self.assertEqual(temperature_unit({}, report('United States'), 'metric', 'en_US'), 'C')
        self.assertEqual(temperature_unit({'temperatureUnit': 'C'}, report('USA'), 'imperial'), 'C')
        self.assertEqual(temperature_unit({'temperatureUnit': 'F'}, report('Canada'), 'metric'), 'F')

    def test_locale_fallback(self):
        for name, expected in [('en_US', 'F'), ('en_LR', 'F'), ('my_MM', 'F'), ('en_CA', 'C'), ('C', 'C')]:
            self.assertEqual(temperature_unit({}, locale_name=name), expected)

    def test_shell_setting(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            target = home / '.config/omarchy/shell.json'
            target.parent.mkdir(parents=True)
            target.write_text(json.dumps({'bar': {'layout': {'center': [{'id': 'omarchy.weather', 'unit': 'imperial'}]}}}))
            self.assertEqual(omarchy_unit(home), 'imperial')

    def test_explicit_labels(self):
        self.assertIn('10°C', format_report(report('Canada'), {}, 'C'))
        self.assertIn('50°F', format_report(report('USA'), {}, 'F'))


if __name__ == '__main__':
    unittest.main()
