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
- `style.css` compiled by concatenating `themes/<theme>.css` + `variants/layout-<profile>.css`

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
- `style.css`: compiled from theme + layout (NOT a symlink anymore).
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

Both profiles use `niri/workspaces` with persistent workspaces 1-5. Scroll actions
call `niri msg action focus-workspace-up` and `niri msg action focus-workspace-down`.

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
- Prefer editing the relevant profile layout file in `variants/layout-<profile>.css`.
- Color tokens live in `themes/<theme>.css` — edit those to change colors, NOT the layout files.
- Layout files must use `@token-name` references and `gtkalpha(@token, opacity)` — no raw color values.
- Keep selectors aligned with module IDs:
  - `#custom-mic`, `#custom-gpu-temp`, `#temperature.cpu`, `#wireplumber.muted`
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
