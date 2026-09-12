# .dotfiles

Personal dotfiles for an Arch Linux/Wayland desktop and macOS.

## Layout

Most top-level configuration directories are GNU Stow packages. Each package
mirrors its destination below `$HOME`; for example, `nvim/.config/nvim` becomes
`~/.config/nvim`. Supporting files such as `assets/`, `utils/`, and
`packages.list/` are shared repository resources rather than application
configuration packages.

## Use GNU Stow

```bash
git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
cd ~/.dotfiles

stow nvim            # Link one package into $HOME
stow -D nvim         # Remove that package's links
stow -R nvim         # Re-create its links
stow --adopt nvim    # Adopt existing files; review changes before committing
```

Install only the packages wanted on the current machine. Inspect pending changes
after using `--adopt`, because it moves the live configuration into this repo.

## After installation

1. Restart your terminal or `source ~/.zshrc`
2. Open tmux and press `Alt-a + I` to install TPM plugins
3. Open Neovim to trigger lazy.nvim plugin installation
