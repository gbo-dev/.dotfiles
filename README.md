# .dotfiles

Personal dotfiles for an Arch Linux / Wayland desktop + MacOS.

## Quick Start

```bash
git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
cd ~/.dotfiles

just install zsh
just install nvim
just install tmux
```

## Structure

Most app and tool directories are stow packages that mirror `$HOME`:

```
~/.dotfiles/
├── alacritty/       Alacritty terminal (Iosevka, Aura theme)
├── fuzzel/          App launcher + power menu overlay
├── ghostty/         Ghostty terminal + GLSL shaders
├── hypr/            Hyprland compositor, hyprlock, hypridle, hyprpaper, wallpapers
├── kitty/           Kitty terminal (alternative)
├── lazygit/         Lazygit TUI (Gruvbox theme)
├── niri/            Niri scrollable tiling compositor (alternative)
├── nvim/            Neovim (lazy.nvim, LSP via Mason, gruvbox-baby)
├── swaync/          Notification center
├── swayidle/        Idle management (Niri) + systemd service
├── swaylock/        Lock screen (Niri)
├── tmux/            tmux (Alt-a prefix, vi keys, TPM)
├── voxtype/         Voice-to-text (Whisper)
├── waybar/          Status bar (vertical/horizontal profiles, custom scripts)
├── zed/             Zed editor (vim mode, Iosevka)
├── zsh/             Zsh shell, aliases, Oh My Zsh
├── utils/           Shell functions and scripts (added to PATH)
├── assets/          Screenshots and other non-config files
├── packages.list/   Reference package lists for per-machine setup
├── deprecated/      Older package lists and assets kept for reference
└── se               Swedish XKB keyboard layout
```

## Using Stow

Stow creates symlinks from `$HOME` into this repository. XDG-compliant apps mirror the `.config` path:

```bash
stow nvim          # ~/.config/nvim -> ~/.dotfiles/nvim/.config/nvim
stow zsh           # ~/.zshrc -> ~/.dotfiles/zsh/.zshrc

stow -D nvim       # Remove symlinks
stow -R nvim       # Re-create symlinks
stow --adopt nvim  # Adopt existing config into dotfiles (overwrites repo files)
```

## Just Recipes

Run `just` to see available recipes. Package actions intentionally target one package at a time, so each system can opt into only the apps it uses:

```bash
just install nvim # Stow one package
just remove nvim  # Remove one package's symlinks
just restow nvim  # Re-create one package's symlinks
just adopt nvim   # Adopt one existing config into dotfiles
just info         # Show installed tool versions
just lint         # Shellcheck all scripts
just clean        # Remove temp files
```

## Utils

The `utils/` directory is added to `$PATH` by `.zshrc` and contains:

| Script | Description |
|--------|-------------|
| `pick` | fzf-based project/config directory picker |
| `functions.zsh` | Shell functions: `pp` (project picker), `config` (config picker), `nws` (multi-dir Neovim workspace) |
| `powermenu-fuzzel` | Power menu (lock, reboot, shutdown, logout) via fuzzel |
| `customize` | Fuzzel menu to toggle waybar layout, transparency, random wallpaper |
| `waybar-profile` | Switch waybar between vertical and horizontal profiles |

## Post-Install

1. Restart your terminal or `source ~/.zshrc`
2. Open tmux and press `Alt-a + I` to install TPM plugins
3. Open Neovim to trigger lazy.nvim plugin installation
