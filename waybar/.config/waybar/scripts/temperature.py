#!/usr/bin/env python3
"""Rediscover hwmon sensors every poll, without caching numbered sysfs paths."""
import json
from pathlib import Path
import sys


def read(path):
    try:
        return path.read_text().strip()
    except OSError:
        return ""


def sensors(root):
    for device in sorted(root.glob('hwmon*')):
        name = read(device / 'name')
        for value in sorted(device.glob('temp*_input')):
            label = read(value.with_name(value.name.replace('_input', '_label')))
            try:
                temperature = int(read(value)) / 1000
            except ValueError:
                continue
            # Broken or disconnected sensors must not become plausible readings.
            if 0 < temperature < 150:
                yield name, label, temperature, value.name


def payload(kind, root=Path('/sys/class/hwmon')):
    readings = list(sensors(root))
    if kind == 'cpu':
        # Driver names identify sensor semantics, unlike boot-dependent hwmon numbers.
        # Prefer package/control sensors; board CPU labels are a conservative fallback.
        candidates = []
        for name, label, value, filename in readings:
            rank = None
            if name in ('k10temp', 'zenpower') and label in ('Tctl', 'Tdie'):
                rank = 0 if label == 'Tctl' else 1
            elif name == 'coretemp' and label.startswith('Package id '):
                rank = 0
            elif name == 'coretemp' and label.startswith('Core '):
                rank = 2
            elif label.casefold() in ('cpu', 'cpu temperature', 'cpu temp'):
                rank = 3
            if rank is not None:
                candidates.append((rank, name, label, value))
        if candidates:
            rank = min(item[0] for item in candidates)
            selected = [item for item in candidates if item[0] == rank]
            _, name, label, value = max(selected, key=lambda item: item[3])
            return {'text': f'{value:.0f}°C',
                    'tooltip': f'CPU: {value:.1f}°C\nSensor: {name} / {label}',
                    'class': 'critical' if value >= 70 else 'normal'}
    else:
        # Only recognised GPU drivers are eligible. Never fall back to an SSD.
        gpu = [(name, label, value, filename) for name, label, value, filename in readings
               if name in ('amdgpu', 'nouveau')]
        primary = [item for item in gpu if item[1] == 'edge' or
                   (item[3] == 'temp1_input' and (item[0] == 'nouveau' or item[1] == ''))]
        if primary:
            name, label, value, _ = max(primary, key=lambda item: item[2])
            detail = '\n'.join(f'{sensor_label or filename}: {temp:.1f}°C'
                               for driver, sensor_label, temp, filename in gpu)
            return {'text': f'{value:.0f}°C', 'tooltip': f'GPU ({name})\n{detail}',
                    'class': 'warning' if value > 70 else 'normal'}
    return {'text': 'N/A', 'tooltip': f'{kind.upper()} temperature unavailable',
            'class': 'unavailable'}


if __name__ == '__main__':
    print(json.dumps(payload(sys.argv[1]), ensure_ascii=False))
