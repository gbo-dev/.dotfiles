# Agent Notes (Waybar)

This directory is a Waybar config + style + scripts bundle.

## Current Setup (Profiles)

We maintain two Waybar profiles:
- `vertical`: left-side vertical bar
- `horizontal`: slim top bar

The active profile is selected via symlinks:
- `config.jsonc` -> `variants/config-<profile>.jsonc`
- `style.css` -> `variants/style-<profile>.css`

Switch profiles with:
- `waybar/.config/waybar/bin/waybar-profile vertical`
- `waybar/.config/waybar/bin/waybar-profile horizontal`

This keeps a stable Waybar entrypoint (`config.jsonc` + `style.css`) while allowing
on-demand switching.

Reference-only implementations (use for inspiration; do NOT edit unless explicitly asked):
- `vertical_modern/`
- `waybar-old/`

## Project Layout

- `config.jsonc`: symlink to the active profile config.
- `style.css`: symlink to the active profile GTK CSS.
- `variants/`: canonical source of truth for per-profile config/style:
  - `variants/config-vertical.jsonc`
  - `variants/style-vertical.css`
  - `variants/config-horizontal.jsonc`
  - `variants/style-horizontal.css`
- `bin/waybar-profile`: switches profiles by updating the symlinks.
- `scripts/`: custom modules and helpers; most return JSON for Waybar `custom/*`.
- Reference-only:
  - `vertical_modern/`
  - `waybar-old/`

## Profile Behavior

### Workspaces (Hyprland)

Both profiles purposefully use per-monitor workspace indexation:
- `DP-1`: `[1, 3, 5]`
- `DP-2`: `[2, 4]`

This is intentional for multi-monitor management: each monitor only shows the workspace
numbers you want associated with it.

### Modules

Horizontal (`variants/config-horizontal.jsonc`):
- left: power, workspaces, tray
- center: time
- right: mic, bluetooth, wireplumber, cpu temp, gpu temp, date

Vertical (`variants/config-vertical.jsonc`):
- left: power, tray
- center: workspaces
- right: mic, bluetooth, wireplumber, cpu temp, gpu temp, time, date

## CSS / Styling Rules

- Waybar uses GTK CSS.
- Prefer editing the relevant profile file in `variants/`.
- Keep selectors aligned with module IDs:
  - `#custom-mic`, `#custom-gpu-temp`, `#temperature.cpu`, `#wireplumber.muted`

## Code Style Guidelines

### General
- Prefer minimal, readable diffs; keep behavior changes scoped to one module or profile.
- Do not change reference-only directories (`vertical_modern/`, `waybar-old/`).

### Shell scripts (`scripts/*.sh`)
- Shebang: `#!/bin/bash`.
- For new/updated scripts: `set -euo pipefail` unless missing deps are expected.
- If a dep/sensor is missing, return a valid JSON payload and exit 0.

## Debugging

- Validate custom scripts by running them directly and piping to `jq`.
- Start Waybar with `-l trace` to diagnose JSON parse/load errors.

