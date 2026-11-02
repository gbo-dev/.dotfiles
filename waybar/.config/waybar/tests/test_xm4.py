import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class XM4Tests(unittest.TestCase):
    def run_helper(self, scenario, timeout=10):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            binary = root / 'bin'
            binary.mkdir()
            stub = binary / 'bluetoothctl'
            stub.write_text('''#!/bin/bash
while [[ "$1" == --* ]]; do shift 2; done
printf '%s\\n' "$*" >> "$XDG_RUNTIME_DIR/calls"
case "$1" in
show) echo 'Powered: yes';;
info)
    if [[ -f "$XDG_RUNTIME_DIR/connected" ]]; then printf 'Paired: yes\\nConnected: yes\\n'
    elif [[ "$SCENARIO" != unpaired* || -f "$XDG_RUNTIME_DIR/paired" ]]; then printf 'Paired: yes\\nConnected: no\\n'
    elif [[ -f "$XDG_RUNTIME_DIR/scanning" ]]; then printf 'Paired: no\\nConnected: no\\n'
    else exit 1; fi;;
connect)
    attempts=$(grep -c '^connect ' "$XDG_RUNTIME_DIR/calls")
    if [[ "$SCENARIO" == lingering ]]; then
        touch "$XDG_RUNTIME_DIR/connected"
        exec sleep 15
    elif [[ "$SCENARIO" == normal || -f "$XDG_RUNTIME_DIR/paired" ]] ||
        [[ "$SCENARIO" == retry && "$attempts" -ge 3 ]]; then
        touch "$XDG_RUNTIME_DIR/connected"
    else echo 'Failed to connect'; exit 1; fi;;
scan)
    touch "$XDG_RUNTIME_DIR/scanning"
    trap 'touch "$XDG_RUNTIME_DIR/scan-stopped"; exit 0' TERM
    while :; do sleep 0.1; done;;
pair)
    if [[ "$SCENARIO" == unpaired_failure ]]; then echo 'Failed to pair'; exit 1; fi
    touch "$XDG_RUNTIME_DIR/paired";;
trust) :;;
esac
''')
            stub.chmod(0o755)
            notifier = binary / 'notify-send'
            notifier.write_text('#!/bin/bash\nprintf "%s\\n" "$*" >> "$XDG_RUNTIME_DIR/notifications"\necho 1\n')
            notifier.chmod(0o755)
            env = dict(os.environ, PATH=f'{binary}:{os.environ["PATH"]}',
                       XDG_RUNTIME_DIR=folder, SCENARIO=scenario)
            subprocess.run(['bash', str(ROOT / 'scripts/xm4-connect.sh')],
                           env=env, capture_output=True, check=True, timeout=timeout)
            return ((root / 'calls').read_text(),
                    (root / 'notifications').read_text(),
                    (root / 'scan-stopped').exists())

    def test_normal_connect_never_removes_pairing(self):
        calls, notifications, stopped = self.run_helper('normal')
        self.assertNotIn('remove ', calls)
        self.assertNotIn('scan ', calls)
        self.assertIn('Connected', notifications)

    def test_connected_is_reported_while_bluetoothctl_lingers(self):
        # bluetoothctl --timeout runs its full length even after connecting;
        # run_helper's 10 s limit fails this if the script waits for it.
        calls, notifications, stopped = self.run_helper('lingering')
        self.assertNotIn('remove ', calls)
        self.assertIn('Connected', notifications)

    def test_failed_connect_is_retried_without_touching_pairing(self):
        calls, notifications, stopped = self.run_helper('retry', timeout=20)
        self.assertEqual(calls.count('connect '), 3)
        self.assertNotIn('remove ', calls)
        self.assertNotIn('scan ', calls)
        self.assertIn('Connected', notifications)

    def test_exhausted_retries_keep_pairing(self):
        calls, notifications, stopped = self.run_helper('unreachable', timeout=20)
        self.assertEqual(calls.count('connect '), 4)
        self.assertNotIn('remove ', calls)
        self.assertNotIn('scan ', calls)
        self.assertNotIn('pair ', calls)
        self.assertIn('Could not connect', notifications)

    def test_unpaired_headset_pairs_only_xm4_and_stops_discovery(self):
        calls, notifications, stopped = self.run_helper('unpaired')
        self.assertNotIn('remove ', calls)
        self.assertIn('pair 80:99:E7:4E:49:64', calls)
        self.assertIn('trust 80:99:E7:4E:49:64', calls)
        self.assertIn('Paired and connected', notifications)
        self.assertTrue(stopped)

    def test_failed_pairing_stops_discovery_without_claiming_success(self):
        calls, notifications, stopped = self.run_helper('unpaired_failure')
        self.assertNotIn('trust ', calls)
        self.assertIn('Pairing failed', notifications)
        self.assertNotIn('Paired and connected', notifications)
        self.assertTrue(stopped)


if __name__ == '__main__':
    unittest.main()
