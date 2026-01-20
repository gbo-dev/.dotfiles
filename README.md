# .dotfiles

![current hyprland config](./hyprland.png)

Uses GNU Stow for dotfiles management. Instead of maintaining your applications' config files across many locations, they are symlinked to the `.dotfiles` directory.

## 🚀 Quick Start

```bash
git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
cd ~/.dotfiles
```

Install stow if you haven't already, now you can import configs by: 

```bash
# Stow a single configuration
stow nvim              # Creates symlinks for neovim config
stow tmux              # Creates symlinks for tmux config
stow zsh               # Creates symlinks for zsh config

# Stow multiple configurations at once
stow nvim tmux zsh

# Remove a configuration (unstow)
stow -D nvim           # Removes neovim config symlinks

# Restow (useful after updating configs)
stow -R nvim           # Remove and re-create symlinks
```

## 📁 Structure

This dotfiles repository is organized for simplicity:

```
~/.dotfiles/
├── nvim/
│   └── .config/nvim/       # Mirrors the .config location
├── tmux/
│   └── .config/tmux/tmux.conf
├── zsh/
│   ├── .zshrc              # Should be placed in $HOME, so no extra .config/zsh/
│   └── .zsh_aliases
├── ghostty/
│   └── .config/ghostty/    
├── zed/
│   └── .config/zed/
└──...
```

The `utils` contains zsh functions, scripts, and a binary `tmux-daily-tasks` which is compiled from, for the time being, a [separate repository](https://github.com/gbo-dev/tmux-daily-tasks).

## 🛠️ Using GNU Stow

GNU Stow creates symlinks from your home directory to the dotfiles in this repository.

> [!NOTE]
> For XDG-compliant applications, configurations need to mirror the directory location relative $HOME. For example, `nvim/.config/nvim/` in this repository will be symlinked to `~/.config/nvim/` in your home directory.

### Adopting Existing Configurations

If you already have configurations in your home directory:

```bash
# Adopt existing configs (moves them into the stow directory)
stow --adopt nvim      # Moves existing nvim config into ~/.dotfiles/nvim/
stow --adopt tmux      # Moves existing tmux config into ~/.dotfiles/tmux/
stow --adopt zsh       # Moves existing zsh config into ~/.dotfiles/zsh/
```

> [!WARNING]
> The `--adopt` flag will move your existing configurations into the dotfiles directory, potentially overwriting what's there.

## 🔧 Post-Configuration

After stowing your configurations:

1. **Restart your terminal** or run `source ~/.zshrc` (or other shell)
2. **Install tmux plugins**: Open tmux and press `prefix + I`
3. **Install Neovim plugins**: Open Neovim to trigger automatic plugin installation

## 📝 Managing Configurations

With the modular structure, you can easily manage individual configurations:

```bash
# Update specific configuration
cd ~/.dotfiles
git add nvim/
git commit -m "Update nvim config"
git push
```

### Backup Existing Configs

Before stowing, you may want to backup your existing configurations.
