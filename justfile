# Dotfiles management recipes

# Package actions intentionally target one package at a time because these
# dotfiles are used across machines with different app sets.

# List available recipes
default:
    @just --list

# Install one dotfile package with GNU Stow (e.g. just install nvim)
install PKG:
    #!/usr/bin/env bash
    set -euo pipefail
    pkg="{{PKG}}"
    if [ ! -d "$pkg" ]; then
        echo "Package '$pkg' not found" >&2
        exit 1
    fi
    echo "Installing $pkg..."
    stow "$pkg" || { echo "Conflict for $pkg, try: just adopt $pkg"; exit 1; }

# Stow terminology alias for install
stow PKG: (install PKG)

# Remove one dotfile package's symlinks
remove PKG:
    #!/usr/bin/env bash
    set -euo pipefail
    pkg="{{PKG}}"
    if [ ! -d "$pkg" ]; then
        echo "Package '$pkg' not found" >&2
        exit 1
    fi
    echo "Removing $pkg..."
    stow -D "$pkg"

# Stow terminology alias for remove
unstow PKG: (remove PKG)

# Re-create one dotfile package's symlinks
restow PKG:
    #!/usr/bin/env bash
    set -euo pipefail
    pkg="{{PKG}}"
    if [ ! -d "$pkg" ]; then
        echo "Package '$pkg' not found" >&2
        exit 1
    fi
    echo "Restowing $pkg..."
    stow -R "$pkg"

# Adopt one existing config into dotfiles
adopt PKG:
    #!/usr/bin/env bash
    set -euo pipefail
    pkg="{{PKG}}"
    if [ ! -d "$pkg" ]; then
        echo "Package '$pkg' not found" >&2
        exit 1
    fi
    echo "Adopting $pkg..."
    stow --adopt "$pkg"
    echo "Review changes with: git diff"

# Apply GTK dark theme settings stored in dconf/gsettings
gtk-theme:
    ./utils/apply-gtk-theme

# Show installed tool versions
info:
    #!/usr/bin/env bash
    echo "System"
    echo "======"
    echo "OS:     $(uname -o) $(uname -r)"
    echo "Arch:   $(uname -m)"
    echo ""
    echo "Tools"
    echo "====="
    command -v nvim  >/dev/null && echo "Neovim:  $(nvim --version | head -1 | cut -d' ' -f2)"  || echo "Neovim:  not installed"
    command -v ghostty >/dev/null && echo "Ghostty: installed"                                    || echo "Ghostty: not installed"
    command -v tmux  >/dev/null && echo "Tmux:    $(tmux -V)"                                    || echo "Tmux:    not installed"
    command -v zsh   >/dev/null && echo "Zsh:     $(zsh --version | cut -d' ' -f1-2)"            || echo "Zsh:     not installed"
    command -v git   >/dev/null && echo "Git:     $(git --version | cut -d' ' -f3)"              || echo "Git:     not installed"
    command -v go    >/dev/null && echo "Go:      $(go version | cut -d' ' -f3)"                 || echo "Go:      not installed"
    command -v rustc >/dev/null && echo "Rust:    $(rustc --version | cut -d' ' -f2)"            || echo "Rust:    not installed"
    command -v node  >/dev/null && echo "Node.js: $(node --version)"                             || echo "Node.js: not installed"
    command -v just  >/dev/null && echo "Just:    $(just --version | cut -d' ' -f2)"             || echo "Just:    not installed"
    command -v stow  >/dev/null && echo "Stow:    $(stow --version 2>&1 | head -1)"              || echo "Stow:    not installed"

# Lint shell scripts with shellcheck
lint:
    #!/usr/bin/env bash
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo "shellcheck not found, install it first"
        exit 1
    fi
    echo "Running shellcheck..."
    find . -name "*.sh" -type f -exec shellcheck {} +
    # Also check extensionless scripts in utils/
    for f in utils/pick utils/powermenu-fuzzel utils/customize utils/waybar-profile utils/tasks; do
        [ -f "$f" ] && shellcheck "$f"
    done
    echo "Done"

# Remove temp and OS junk files
clean:
    #!/usr/bin/env bash
    find . -name "*.tmp" -type f -delete 2>/dev/null || true
    find . -name "*.log" -type f -delete 2>/dev/null || true
    find . -name ".DS_Store" -type f -delete 2>/dev/null || true
    echo "Cleaned"
