# Agent Notes (Waybar)

This directory is a Waybar config + style + scripts bundle.

## Current Setup (Profiles + Themes)

We maintain two Waybar profiles:
- `vertical`: left-side vertical bar
- `horizontal`: slim top bar

And a theme system with tokenized CSS colors:
- `themes/default.css`: `@define-color` tokens (bg, fg, accent, workspace colors, etc.)
- Layout files in `variants/` reference tokens via `@token-name` and `gtkalpha(@token, opacity)`.

The active profile is activated by:
- `config.jsonc` symlinked to `variants/config-<profile>.jsonc`
- `style.css` compiled by concatenating `themes/<theme>.css` + `variants/common.css` + `variants/layout-<profile>.css` + `variants/states.css`

Switch with:
- `waybar-profile [vertical|horizontal] [theme]`
  - e.g. `waybar-profile vertical` (keeps current theme)
  - e.g. `waybar-profile vertical catppuccin-mocha` (switches theme too)
  - no args toggles between vertical/horizontal

Reference-only implementations (use for inspiration; do NOT edit unless explicitly asked):
- `vertical_modern/`
- `waybar-old/`

## Project Layout

- `config.jsonc`: symlink to the active profile config.
- `style.css`: compiled from theme + common + layout + states (NOT a symlink anymore).
- `.waybar-theme`: tracks current theme name.
- `themes/`: `@define-color` token files (one per theme).
  - `themes/default.css`
- `variants/`: per-profile config and layout:
  - `variants/config-vertical.jsonc`
  - `variants/layout-vertical.css` (uses @color tokens, no raw colors)
  - `variants/config-horizontal.jsonc`
  - `variants/layout-horizontal.css` (uses @color tokens, no raw colors)
  - `variants/style-vertical.css` (legacy, kept for reference)
  - `variants/style-horizontal.css` (legacy, kept for reference)
- `~/.dotfiles/utils/waybar-profile`: switches profiles/themes, compiles CSS.
- `scripts/`: custom modules and helpers; most return JSON for Waybar `custom/*`.
- Reference-only:
  - `vertical_modern/`
  - `waybar-old/`

## Profile Behavior

### Workspaces (Niri)

Both profiles use `niri/workspaces` to display Niri's actual dynamic workspaces.
Diamonds indicate occupancy: filled means a window is present; hollow means empty.
Persistence belongs in Niri configuration, not in this module. Scroll actions
call `niri msg action focus-workspace-up` and `niri msg action focus-workspace-down`.

### Modules

Horizontal (`variants/config-horizontal.jsonc`):
- left: power, workspaces
- center: (empty)
- right: tray, mic, bluetooth, wireplumber, cpu temp, gpu temp, clock

Vertical (`variants/config-vertical.jsonc`):
- left: power, workspaces
- center: stacked clock
- right: tray, mic, bluetooth, wireplumber, cpu temp, gpu temp

## CSS / Styling Rules

- Waybar uses GTK CSS.
- Prefer editing the relevant profile layout file in `variants/layout-<profile>.css`.
- Color tokens live in `themes/<theme>.css` — edit those to change colors, NOT the layout files.
- Layout files must use `@token-name` references and `gtkalpha(@token, opacity)` — no raw color values.
- Keep selectors aligned with module IDs:
  - `#custom-mic`, `#custom-gpu-temp`, `#custom-cpu-temp`, `#wireplumber.muted`
- `variants/style-*.css` are legacy (pre-token) and kept for reference only.

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

## Reliability and validation

- Horizontal is the visual baseline. Common typography, tooltips, and menus live
  in `variants/common.css`; neutral status styling lives in `variants/states.css`.
  Vertical retains its width, vertical spacing, and stacked clock.
- `scripts/temperature.py` discovers sensors on every poll by driver identity
  and label. CPU selection prefers k10temp/zenpower Tctl/Tdie and coretemp package
  readings, then cores, then explicit CPU board labels. GPU selection recognises
  amdgpu/nouveau. Unknown sensors return N/A rather than using unrelated readings.
  New hardware may need an additional recognised driver/label. No hwmon number is cached.
- Preserve existing temperature thresholds; hardware-specific hotspot limits need
  a deliberate decision, not the CPU/edge threshold copied onto another sensor.
- Dependencies: Python 3 standard library, jq, and existing desktop tools.
- Run `just --justfile ~/.config/waybar/justfile check` for sensor renumbering,
  disappearance/recovery, failed audio/Bluetooth operations, JSON escaping,
  profile switching, config parsing, and shell syntax checks.
