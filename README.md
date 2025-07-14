# .dotfiles

Simple and elegant automated setup for Linux development environments. Uses GNU Stow for dotfiles management with a streamlined installation process focused on core development tools.

## 🚀 Quick Start

For a fresh Linux machine:

```bash
# Clone the repository (requires git)
git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
cd ~/.dotfiles

# Run full installation - installs everything with sensible defaults
make install
```

> **Note**: If you don't have `git` installed, install it manually first:
> ```bash
> sudo apt update && sudo apt install -y git
> ```

The installation will:
- Install prerequisites (make, git, curl, build-essential, zsh, stow)
- Install modern CLI tools (ripgrep, fzf, bat, fd-find, etc.)
- Install and configure editors (Neovim, Zed)
- Install development tools (Docker, Node.js, Rust, Go)
- Install terminal applications (Ghostty, Nerd Fonts)
- Configure zsh with Oh My Zsh and switch to zsh shell
- Apply all dotfile configurations using Stow
- Setup tmux with plugin manager

## 📁 Structure

This dotfiles repository is organized for simplicity:

```
~/.dotfiles/
├── lib/                    # Shared functions and utilities
├── nvim/                   # Neovim configuration
├── tmux/                   # Tmux configuration
├── zsh/                    # Zsh configuration
├── ghostty/                # Ghostty terminal config
├── zed/                    # Zed editor config
├── alacritty/              # Alacritty terminal config (optional)
├── kitty/                  # Kitty terminal config (optional)
├── install.sh              # Main installation script
├── Makefile               # Simple automation commands
└── packages.list          # System packages list
```

## 🛠️ Installation Options

### Simple Installation Commands

```bash
# Full installation with sensible defaults (recommended)
make install

# Interactive installation - choose what to install
make install-interactive

# Minimal installation - essential tools only
make install-minimal

# Apply configurations only (if already installed)
make stow
```

### What Gets Installed

**Always installed:**
- Prerequisites: make, git, curl, build-essential, zsh, stow
- System packages: ripgrep, fzf, bat, fd-find, tmux, htop, tree
- Neovim (latest stable)
- Docker and Node.js
- Nerd Fonts and terminal setup

**Default installation (non-interactive):**
- VS Code and Zed editors
- Rust and Go toolchains
- Database clients (PostgreSQL, SQLite)
- Additional dev tools (httpie, shellcheck, imagemagick)

**Interactive mode options:**
- Choose individual development tools and optional components

### Advanced Usage

For more control over the installation:

```bash
# Run the installation script directly with options
./install.sh --help                    # Show all options
./install.sh --interactive             # Interactive mode
./install.sh --minimal                 # Essential tools only
./install.sh --no-development          # Skip development tools
./install.sh --skip zed neovim         # Skip specific packages
./install.sh --debug                   # Enable debug output
```

Available installation script options:
- `--interactive`: Ask before installing optional components
- `--minimal`: Install only essential tools
- `--skip <packages>`: Skip specific packages (e.g., `--skip zed docker`)
- `--no-prerequisites`: Skip prerequisites installation
- `--no-packages`: Skip system packages
- `--no-editors`: Skip editors installation
- `--no-development`: Skip development tools
- `--no-terminals`: Skip terminal applications
- `--no-dotfiles`: Skip dotfiles setup

**Packages you can skip**: `neovim`, `vscode`, `zed`, `docker`, `nodejs`, `rust`, `go`, `databases`, `devtools`, `fonts`, `ghostty`

## 🔄 Installing on a machine with existing configs

> [!WARNING]
> The `--adopt` flag will overwrite the contents of your dotfiles directory with the contents from your target directory.

If you already have existing configurations you want to back up or adopt:

```bash
# Create backup and adopt existing configs
make adopt

# Or manually backup and adopt
make backup
stow nvim --adopt      # Adopts existing nvim config
stow tmux --adopt      # Adopts existing tmux config
stow zsh --adopt       # Adopts existing zsh config
```

## ⚙️ What Gets Installed

### Core System Tools
- **Modern CLI**: ripgrep, fzf, bat, fd-find, tree, htop
- **Development essentials**: build-essential, git, curl, make, tmux
- **Shell**: zsh with Oh My Zsh and autosuggestions

### Editors
- **Neovim** (latest stable) - Always installed
- **VS Code** (latest) - Always installed
- **Zed** (latest) - High-performance editor (default)

### Development Tools
- **Container platform**: Docker with Docker Compose
- **Runtime environments**: Node.js (LTS via nvm)
- **Programming languages**: Rust, Go (default installation)
- **Database clients**: PostgreSQL client, SQLite
- **Additional tools**: httpie, shellcheck, imagemagick, ffmpeg

### Terminal & Fonts
- **Terminal**: Ghostty (when available)
- **Fonts**: Adwaita Mono and JetBrainsMono Nerd Fonts
- **Configuration**: All terminals pre-configured

### Architecture Support
- **Linux x86_64**: Full support for all tools
- **Linux ARM64**: Core tools with architecture-specific binaries
- **macOS ARM64**: Planned future support

## 🎯 Available Commands

```bash
# Main installation commands
make install            # Full automatic installation (recommended)
make install-interactive # Interactive installation with choices
make install-minimal    # Minimal installation (essential tools only)

# Configuration management
make stow              # Apply dotfile configurations only
make unstow            # Remove dotfile configurations
make adopt             # Backup and adopt existing configs

# Component installation (for advanced users)
make deps              # Install system packages only
make editors           # Install editors only
make development       # Install development tools only
make terminals         # Install terminal applications only

# Maintenance and utilities
make clean             # Clean temporary files
make test              # Run validation tests
make lint              # Run linting checks
make check             # Run all checks
make info              # Show installed tool versions
make help              # Show all available commands
```

## 🔧 Post-Installation

After installation completes:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Open tmux and press `prefix + I`** to install tmux plugins
3. **Open Neovim** to trigger plugin installation
4. **Log out and back in** for Docker group changes to take effect

The installation script will show you exactly what was installed and any manual steps needed.

## 📝 Managing Configurations

With the modular structure, you can easily manage individual configurations:

```bash
# Update specific configuration
cd ~/.dotfiles
git add nvim/
git commit -m "Update nvim config"

# Remove and re-apply specific config
stow -D tmux    # Remove tmux config
stow tmux       # Re-apply tmux config

# Install specific components only
./install.sh --no-packages --no-development  # Editors and terminals only
make editors                                  # Legacy: editors only
```

## 🔍 Useful Features

### Config Selector
The zsh configuration includes a `config` function for quick access:
```bash
config          # Interactive selection with fzf
config nvim     # Direct access to neovim config
config dir zsh  # Navigate to zsh config directory
```

### Installation Flexibility
The installation script provides flexible options:
```bash
./install.sh --help              # Show all available options
./install.sh --interactive       # Choose optional components
./install.sh --minimal          # Essential tools only
./install.sh --skip zed docker   # Skip specific packages
./install.sh --debug            # Verbose installation output
```

### Skip Specific Packages
If some tools are already installed or causing issues, you can skip them:
```bash
# Skip editors that are already installed
./install.sh --skip zed neovim

# Skip development tools that failed before
./install.sh --skip docker rust go

# Skip terminal applications
./install.sh --skip ghostty fonts
```

### Configuration Conflict Handling
If you have existing configurations that conflict with the dotfiles:
```bash
# The script will automatically:
# 1. Skip configurations for skipped programs
./install.sh --skip zed  # Won't try to apply zed config

# 2. Adopt existing files when conflicts occur
# Your existing ~/.config/zed/settings.json will be preserved
# and merged into the dotfiles repository

# 3. Continue installation even if some configs fail
# Script won't abort on configuration conflicts
```

The installation uses these strategies:
- **Smart skipping**: Configurations are skipped when their programs are skipped
- **Conflict adoption**: Existing files are preserved and adopted into dotfiles
- **Graceful continuation**: Script continues even when some configurations fail
- **Clear feedback**: Shows exactly what was applied, adopted, or skipped

## 🛡️ Security & Reliability

- Scripts refuse to run as root for security
- All downloads use HTTPS and verify sources when possible
- Existing configurations are automatically preserved via adoption
- Architecture detection prevents incompatible binary installation
- Comprehensive error handling and recovery
- Graceful handling of configuration conflicts

## 💡 Benefits

- **🚀 Fast Setup**: Single command for complete development environment
- **🎯 Focused**: Core tools without unnecessary complexity
- **🔄 Reproducible**: Identical setup across all machines
- **📦 Current**: Latest stable versions of all tools
- **🛠️ Maintainable**: Simple structure, easy to customize
- **🏗️ Architecture Aware**: Supports x86_64 and ARM64 Linux systems
- **📋 Clear**: Minimal, well-documented approach
