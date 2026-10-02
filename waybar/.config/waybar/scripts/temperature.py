#!/usr/bin/env python3
"""Rediscover hwmon sensors every poll, without caching numbered sysfs paths."""
import argparse
import json
from pathlib import Path
import time


def read(path):
    try:
        return path.read_text().strip()
    except OSError:
        return ""


# Advisory threshold, shared by CPU package and GPU core readings.
WARNING_C = 70


def cpu_rank(name, label):
    if name in ('k10temp', 'zenpower') and label in ('Tctl', 'Tdie'):
        return 0 if label == 'Tctl' else 1
    if name == 'coretemp' and label.startswith('Package id '):
        return 0
    if name == 'coretemp' and label.startswith('Core '):
        return 2
    if label.casefold() in ('cpu', 'cpu temperature', 'cpu temp'):
        return 3
    return None


def reading_payload(kind, value, detail):
    hot = value >= WARNING_C
    tooltip = detail
    if hot:
        tooltip += f'\nWarning: {kind.upper()} temperature is at or above {WARNING_C}°C'
    return {'text': f'{value:.0f}°C', 'tooltip': tooltip,
            'class': 'warning' if hot else 'normal'}


def sensors(root, kind):
    for device in sorted(root.glob('hwmon*')):
        name = read(device / 'name')
        if kind == 'gpu' and name not in ('amdgpu', 'nouveau'):
            continue
        for value in sorted(device.glob('temp*_input')):
            label = read(value.with_name(value.name.replace('_input', '_label')))
            if kind == 'cpu' and cpu_rank(name, label) is None:
                continue
            try:
                temperature = int(read(value)) / 1000
            except ValueError:
                continue
            # Broken or disconnected sensors must not become plausible readings.
            if 0 < temperature < 150:
                yield name, label, temperature, value.name


def payload(kind, root=Path('/sys/class/hwmon')):
    readings = list(sensors(root, kind))
    if kind == 'cpu':
        # Driver names identify sensor semantics, unlike boot-dependent hwmon numbers.
        # Prefer package/control sensors; board CPU labels are a conservative fallback.
        candidates = []
        for name, label, value, filename in readings:
            rank = cpu_rank(name, label)
            if rank is not None:
                candidates.append((rank, name, label, value))
        if candidates:
            rank = min(item[0] for item in candidates)
            selected = [item for item in candidates if item[0] == rank]
            _, name, label, value = max(selected, key=lambda item: item[3])
            return reading_payload(kind, value, f'CPU: {value:.1f}°C')
    else:
        # Only recognised GPU drivers are eligible. Never fall back to an SSD.
        gpu = [(name, label, value, filename) for name, label, value, filename in readings
               if name in ('amdgpu', 'nouveau')]
        primary = [item for item in gpu if item[1] == 'edge' or
                   (item[3] == 'temp1_input' and (item[0] == 'nouveau' or item[1] == ''))]
        if primary:
            name, label, value, _ = max(primary, key=lambda item: item[2])
            labels = {'edge': 'GPU', 'junction': 'Hotspot', 'mem': 'Memory'}
            detail = '\n'.join(f'{labels.get(sensor_label, "GPU")}: {temp:.1f}°C'
                               for driver, sensor_label, temp, filename in gpu)
            return reading_payload(kind, value, detail)
    return {'text': 'N/A', 'tooltip': f'{kind.upper()} temperature unavailable',
            'class': 'unavailable'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kind', choices=('cpu', 'gpu'))
    parser.add_argument('--watch', type=float, help='Stream JSON at this interval in seconds')
    args = parser.parse_args()
    if args.watch is not None and args.watch <= 0:
        parser.error('--watch must be positive')
    while True:
        print(json.dumps(payload(args.kind), ensure_ascii=False), flush=True)
        if args.watch is None:
            break
        time.sleep(args.watch)
