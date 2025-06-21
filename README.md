# .dotfiles

Maintained using GNU Stow for symlink management. Assumes debian-based system.

## Structure

This dotfiles repository is organized by application, with each application having its own directory:

```
~/.dotfiles/
├── nvim/
│   └── .config/
│       └── nvim/
├── tmux/
│   └── .config/
│       └── tmux/
├── zsh/
│   ├── .zshrc
│   ├── .zsh_aliases
│   └── .oh-my-zsh/
├── ghostty/
│   └── .config/
│       └── ghostty/
└── shared/
    ├── utilities/
    └── scripts/
```

## Installing on a fresh machine

1. Clone this repository to your home directory:
   ```bash
   git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
   ```

2. Navigate to the dotfiles directory:
   ```bash
   cd ~/.dotfiles
   ```

3. For each application you want to configure, stow its directory:
   ```bash
   stow nvim      # Symlinks Neovim config
   stow tmux      # Symlinks tmux config
   stow zsh       # Symlinks zsh config and aliases
   # ... etc for other applications
   ```

## Installing on a machine with existing configs

> [!WARNING]
> The `--adopt` flag will overwrite the contents of your dotfiles directory with the contents from your target directory.

If you already have existing configurations you want to back up or adopt:

1. Clone the repo and cd into it
2. For each application that already exists on the machine, use the `--adopt` flag:
   ```bash
   stow nvim --adopt      # Adopts existing nvim config
   stow tmux --adopt      # Adopts existing tmux config
   stow zsh --adopt       # Adopts existing zsh config
   ```

## Application-Specific Setup

### Neovim

Install the latest version of Neovim:
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
```

Add to your PATH by adding this line to your shell profile:
```bash
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

### Tmux

Install tmux (if not already available via package manager):
```bash
sudo apt install tmux
```

Install TPM (Tmux Plugin Manager):
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After stowing the tmux config, reload tmux and install plugins:
```bash
# Reload tmux config
tmux source ~/.config/tmux/tmux.conf

# Install plugins (from within tmux session)
# Press prefix + I (capital i) to install plugins
```

### Zsh

Install zsh and oh-my-zsh:
```bash
sudo apt install zsh
# Set zsh as default shell
chsh -s $(which zsh)
```

Oh-my-zsh is included in the dotfiles, so it will be symlinked when you stow zsh.

## Managing Individual Applications

With this structure, you can easily manage configurations for individual applications:

```bash
# Update only Neovim config
cd ~/.dotfiles
git add nvim/
git commit -m "Update nvim config"

# Remove tmux config temporarily
stow -D tmux

# Re-apply tmux config
stow tmux
```

## Security

Ensure correct permissions after cloning:
```bash
chmod 700 ~/.dotfiles
find ~/.dotfiles -name "*.sh" -exec chmod 755 {} \;
```

## Benefits of This Structure

- **Modular**: Each application is self-contained
- **Selective**: Install only the configs you need
- **Clear**: Easy to understand what belongs to which application
- **Maintainable**: Easy to update individual application configs
- **Shareable**: Others can pick and choose specific application configs
