# .dotfiles

Maintained using GNU Stow for symlink management. Assumes debian-based system.

## Installing on a fresh machine

1. Clone this repository to your home directory:
   ```bash
   git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
   ```

2. For each package in the repo that you want symlinked, run:
   ```bash
   stow <package> # For exmaple: stow .zshrc
   ```

## Installing on a machine with Existing Configs

> [!WARNING]
> The `--adopt` flag will overwrite the contents of your dotfiles directory with the contents from your target directory.

If you already have existing configurations you want to back up or adopt:

1. Clone the repo and cd into it
2. For each package that already exists on the machine, use the `--adopt` flag:
   ```bash
   stow <package> --adopt # For example: stow .zshrc --adopt
   ```

## Neovim

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

## Tmux

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
tmux source ~/.tmux.conf

# Install plugins (from within tmux session)
# Press prefix + I (capital i) to install plugins
```

## Security

Ensure correct permissions after cloning:
```bash
chmod 700 ~/.dotfiles
chmod 600 ~/.dotfiles/utilities/shell-scripts/*.sh
```

---

*Stow workflow inspired by [bashbunni's dotfiles](https://github.com/bashbunni/dotfiles)*
