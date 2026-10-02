import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SensorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def payload(self, kind):
        result = subprocess.run(['bash', str(ROOT / 'scripts/temperature.sh'), kind,
                                 '--hwmon-root', str(self.root)], capture_output=True,
                                text=True, check=True)
        return json.loads(result.stdout)

    def sensor(self, number, name, values):
        device = self.root / f'hwmon{number}'
        device.mkdir()
        (device / 'name').write_text(name)
        for number, label, value in values:
            (device / f'temp{number}_label').write_text(label)
            (device / f'temp{number}_input').write_text(str(value))
        return device

    def test_renumbering_disappearance_and_recovery(self):
        self.sensor(3, 'nvme', [(1, 'Composite', 31000)])
        cpu = self.sensor(4, 'k10temp', [(1, 'Tctl', 43500)])
        self.assertEqual(self.payload('cpu')['text'], '44°C')
        cpu.rename(self.root / 'hwmon19')
        self.assertEqual(self.payload('cpu')['text'], '44°C')
        shutil.rmtree(self.root / 'hwmon19')
        self.assertEqual(self.payload('cpu')['class'], 'unavailable')
        self.sensor(30, 'coretemp', [(1, 'Package id 0', 55000)])
        self.assertEqual(self.payload('cpu')['text'], '55°C')

    def test_cpu_fallback_and_invalid_inputs(self):
        cpu = self.sensor(9, 'k10temp', [(1, 'Tctl', 'bad')])
        self.sensor(10, 'asus_wmi_sensors', [(1, 'CPU Temperature', 41000),
                                          (2, 'CPU Socket Temperature', 27000),
                                          (5, 'Tsensor 1 Temperature', 216000)])
        self.assertEqual(self.payload('cpu')['text'], '41°C')
        (cpu / 'temp1_input').write_text('71000')
        self.assertEqual(self.payload('cpu')['class'], 'warning')

    def test_warning_threshold_for_both_modules(self):
        cpu = self.sensor(4, 'k10temp', [(1, 'Tctl', 69999)])
        gpu = self.sensor(8, 'amdgpu', [(1, 'edge', 69999)])
        for kind, device in (('cpu', cpu), ('gpu', gpu)):
            self.assertEqual(self.payload(kind)['class'], 'normal')
            (device / 'temp1_input').write_text('70000')
            result = self.payload(kind)
            self.assertEqual(result['class'], 'warning')
            self.assertIn('Warning:', result['tooltip'])
            self.assertIn(kind.upper(), result['tooltip'])
            (device / 'temp1_input').write_text('40000')
            self.assertEqual(self.payload(kind)['class'], 'normal')

    def test_gpu_optional_sensors_and_renumbering(self):
        self.sensor(2, 'nvme', [(1, 'Composite', 36000)])
        gpu = self.sensor(8, 'amdgpu', [(1, 'edge', 32000), (2, 'junction', 'bad')])
        self.assertEqual(self.payload('gpu')['text'], '32°C')
        gpu.rename(self.root / 'hwmon42')
        self.assertEqual(self.payload('gpu')['text'], '32°C')
        shutil.rmtree(self.root / 'hwmon42')
        self.assertEqual(self.payload('gpu')['class'], 'unavailable')
    def test_stream_caches_paths_and_recovers_on_failed_read(self):
        import select
        cpu = self.sensor(4, 'k10temp', [(1, 'Tctl', 43000)])
        bin_dir = self.root / 'bin'
        bin_dir.mkdir()
        calls = self.root / 'discovery-calls'
        real_readlink = shutil.which('readlink')
        stub = bin_dir / 'readlink'
        stub.write_text(f'#!/bin/bash\necho scan >> "{calls}"\nexec "{real_readlink}" "$@"\n')
        stub.chmod(0o755)
        env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}')
        process = subprocess.Popen(['bash', str(ROOT / 'scripts/temperature.sh'),
                                    'cpu', '--watch', '0.1', '--hwmon-root', str(self.root)],
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                   env=env, text=True)
        def update():
            ready, _, _ = select.select([process.stdout], [], [], 3)
            self.assertTrue(ready, 'Temperature stream stopped')
            return json.loads(process.stdout.readline())
        try:
            self.assertEqual(update()['text'], '43°C')
            self.assertEqual(update()['text'], '43°C')
            self.assertEqual(len(calls.read_text().splitlines()), 1,
                             'Steady updates should use the cached path')
            cpu.rename(self.root / 'hwmon19')
            for _ in range(5):
                update()
                if len(calls.read_text().splitlines()) > 1:
                    break
            self.assertGreater(len(calls.read_text().splitlines()), 1)
            self.assertEqual(update()['text'], '43°C')
            shutil.rmtree(self.root / 'hwmon19')
            for _ in range(5):
                if update()['class'] == 'unavailable':
                    break
            else:
                self.fail('Removed sensor should show unavailable')
        finally:
            process.terminate()
            process.communicate(timeout=3)



class HelperTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}', HOME=str(self.root))

    def stub(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/bash\n' + body)
        path.chmod(0o755)

    def run_script(self, name, *args):
        return subprocess.run(['bash', str(ROOT / 'scripts' / name), *args],
                              env=self.env, capture_output=True, text=True, check=True)

    def test_microphone_failure_and_mute_are_distinct(self):
        self.stub('pactl', 'exit 1\n')
        data = json.loads(self.run_script('mic.sh').stdout)
        self.assertEqual(data['class'], 'unavailable')
        self.assertEqual(data['text'], '󰍬')
        self.stub('pactl', 'if [[ "$1" == get-default-source ]]; then echo test-source; '
                  'else echo "Mute: yes"; fi\n')
        data = json.loads(self.run_script('mic.sh').stdout)
        self.assertEqual(data['class'], 'muted')
        self.assertEqual(data['text'], '󰍭')

    def test_power_tooltip_escapes_external_text(self):
        # ip output is external data just like an SSID; JSON must preserve it.
        self.stub('ip', 'if [[ "$1" == route ]]; then echo '\
                  "'1.1.1.1 dev quoted\"iface\\name src 192.0.2.1'; "\
                  'else echo "inet 192.0.2.1/24"; fi\n')
        data = json.loads(self.run_script('power-menu.sh').stdout)
        self.assertIn('quoted"iface\\name', data['tooltip'])
        self.assertIn('\n\nInterface:', data['tooltip'])

    def test_bluetooth_does_not_announce_failed_toggle(self):
        self.stub('bluetoothctl', 'if [[ "$1" == show ]]; then echo "Powered: no"; '
                  'else echo "Failed to set power on"; exit 1; fi\n')
        self.stub('notify-send', 'printf "%s\\n" "$*" >> "$HOME/notifications"; echo 1\n')
        self.env['XDG_RUNTIME_DIR'] = str(self.root)
        self.run_script('bluetooth.sh')
        notification = (self.root / 'notifications').read_text()
        self.assertIn('Could not change controller power', notification)
        self.assertNotIn('Enabled', notification)

    def test_profile_compiles_both_layouts_and_preserves_on_failure(self):
        dotfiles = self.root / '.dotfiles/waybar/.config'
        dotfiles.mkdir(parents=True)
        (dotfiles / 'waybar').symlink_to(ROOT)
        config = self.root / '.config/waybar'
        config.mkdir(parents=True)
        self.stub('killall', 'exit 0\n')
        profile = ROOT / 'waybar-profile'
        # In the real repository the helper lives under utils.
        if not profile.exists():
            profile = ROOT.parents[2] / 'utils/waybar-profile'
        for layout in ('vertical', 'horizontal'):
            subprocess.run(['bash', str(profile), layout, 'quartz'], env=self.env,
                           capture_output=True, check=True)
            expected = b''.join((ROOT / name).read_bytes() for name in (
                'themes/quartz.css', 'variants/common.css',
                f'variants/layout-{layout}.css', 'variants/states.css'))
            self.assertEqual((config / 'style.css').read_bytes(), expected)
            self.assertEqual((config / 'config.jsonc').resolve(),
                             (ROOT / f'variants/config-{layout}.jsonc').resolve())
        before = (config / 'style.css').read_bytes()
        result = subprocess.run(['bash', str(profile), 'vertical', 'nonexistent'],
                                env=self.env, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((config / 'style.css').read_bytes(), before)
        self.assertTrue((config / 'config.jsonc').resolve().name.endswith('horizontal.jsonc'))

    def test_temperature_streams_multiple_json_updates(self):
        import select
        process = subprocess.Popen(['bash', str(ROOT / 'scripts/temperature.sh'),
                                    'cpu', '--watch', '0.05'], stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, text=True)
        try:
            for _ in range(2):
                ready, _, _ = select.select([process.stdout], [], [], 3)
                self.assertTrue(ready, 'Streaming helper stopped producing updates')
                data = json.loads(process.stdout.readline())
                self.assertIn(data['class'], ('normal', 'warning', 'unavailable'))
        finally:
            process.terminate()
            process.communicate(timeout=3)

    def test_configs_and_shell_syntax(self):
        for config in (ROOT / 'variants').glob('config-*.jsonc'):
            json.loads(re.sub(r',\s*([}\]])', r'\1', config.read_text()))
        for script in (ROOT / 'scripts').glob('*.sh'):
            subprocess.run(['bash', '-n', str(script)], check=True)


if __name__ == '__main__':
    unittest.main()
