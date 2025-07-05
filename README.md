# .dotfiles

Automated dotfiles setup for Linux development environments. Maintained using GNU Stow for symlink management with automated installation scripts for a complete development setup.

## 🚀 Quick Start (Recommended)

For a fresh Linux machine:

```bash
# Clone the repository (requires git)
git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
cd ~/.dotfiles

# First, install basic prerequisites if needed
make prerequisites

# Then run automated setup (installs everything)
make install
```

> **Note**: If you don't have `git`, `make`, or `curl` installed, run the prerequisites step first or install them manually:
> ```bash
> sudo apt update && sudo apt install -y git make curl build-essential
> ```

The full installation will:
- Check and install prerequisites (make, git, curl, build-essential)
- Install all system packages and dependencies
- Install and configure Oh My Zsh with zsh as default shell
- Install latest versions of Neovim, Zed, VS Code, and Ghostty
- Install development tools (Docker, Rust, Go, Node.js, etc.)
- Apply all dotfile configurations using Stow
- Install tmux plugin manager and configure plugins

## 📁 Structure

This dotfiles repository is organized by application:

```
~/.dotfiles/
├── install/                 # Installation scripts
│   ├── apt-packages.sh     # System packages
│   ├── editors.sh          # Neovim, Zed, VS Code
│   ├── terminals.sh        # Ghostty, fonts
│   └── development.sh      # Dev tools & languages
├── nvim/                   # Neovim configuration
├── tmux/                   # Tmux configuration
├── zsh/                    # Zsh configuration
├── ghostty/                # Ghostty terminal config
├── zed/                    # Zed editor config
├── alacritty/              # Alacritty terminal config
├── kitty/                  # Kitty terminal config
├── shared/                 # Shared utilities
├── setup.sh               # Main setup script
├── Makefile               # Automation commands
└── packages.list          # System packages list
```

## 🛠️ Prerequisites

Before running the main installation, ensure you have the basic tools:

```bash
# Check if prerequisites are installed
make prerequisites --verify

# Install prerequisites if missing
make prerequisites
```

**Required tools:**
- `make` - Build automation
- `git` - Version control
- `curl` - Data transfer
- `build-essential` - Compilation tools

## 🛠️ Installation Options

### Automated Installation (Recommended)

```bash
# Full installation
make install

# Individual components
make editors      # Install editors only
make terminals    # Install terminals only
make dev         # Install dev tools only
make deps        # Install system packages only
make stow        # Apply configurations only
```

### Manual Installation

For more control over the installation process:

1. Clone this repository:
   ```bash
   git clone https://github.com/gbo-dev/.dotfiles ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run individual installation scripts:
   ```bash
   # Install system packages
   ./install/apt-packages.sh

   # Install editors
   ./install/editors.sh

   # Install terminals
   ./install/terminals.sh

   # Install development tools
   ./install/development.sh
   ```

3. Apply configurations:
   ```bash
   # Apply all configurations
   make stow

   # Or apply individual configs
   stow nvim tmux zsh
   ```

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

### Editors
- **Neovim** (latest stable) - Modern Vim-based editor
- **Zed** (latest) - High-performance collaborative editor
- **VS Code** (latest) - Microsoft's popular editor
- Language servers for TypeScript, Python, Bash, YAML, etc.

### Terminal Applications
- **Ghostty** (latest) - Fast, feature-rich terminal
- **Alacritty** - GPU-accelerated terminal (optional)
- **Kitty** - Feature-rich terminal (optional)
- **FiraCode** and **JetBrainsMono** Nerd Fonts

### Development Tools
- **Languages**: Rust, Go, Node.js (LTS), Python tools
- **Containers**: Docker with Docker Compose
- **Database clients**: PostgreSQL, MySQL, SQLite, Redis
- **Additional tools**: jq, httpie, gh (GitHub CLI), tree, and more

### System Packages
All packages from the consolidated `packages.list` file (22+ essential packages):
- **Core tools**: Git, build-essential, curl, wget, tree, jq
- **Modern CLI**: ripgrep, fzf, bat, fd-find
- **Development**: tmux, zsh, stow, htop, make, gcc
- **System libraries**: apt-transport-https, ca-certificates, gnupg
- **Languages**: Python3, Node.js, npm
- **Fonts**: FiraCode, Hack, Powerline fonts

## 🎯 Available Commands

```bash
# Main commands
make install      # Full setup for new machine
make setup        # Run setup script only
make stow         # Apply dotfile configurations
make unstow       # Remove dotfile configurations

# Individual components
make deps         # Install system packages
make editors      # Install editors (neovim, zed, vscode)
make terminals    # Install terminal applications
make dev          # Install development tools

# Maintenance
make update       # Update all installed tools
make clean        # Clean temporary files
make backup       # Backup existing configs
make adopt        # Backup and adopt existing configs

# Information
make info         # Show installed tool versions
make help         # Show all available commands
```

## 🔧 Post-Installation

After running the setup, you may need to:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Open tmux and press `prefix + I`** to install tmux plugins
3. **Open Neovim** to trigger plugin installation
4. **Log out and back in** for Docker group changes to take effect

## 📝 Managing Individual Applications

With this modular structure, you can easily manage configurations:

```bash
# Update only Neovim config
cd ~/.dotfiles
git add nvim/
git commit -m "Update nvim config"

# Remove tmux config temporarily
stow -D tmux

# Re-apply tmux config
stow tmux

# Install only specific components
./install/editors.sh --neovim-only
./install/development.sh --docker-only
```

## 🔍 Useful Features

### Config Selector
The zsh configuration includes a `config` function for quick access:
```bash
config          # Interactive selection with fzf
config nvim     # Direct access to neovim config
config dir zsh  # Navigate to zsh config directory
```

### Script Options
All installation scripts support options:
```bash
./install/editors.sh --help        # Show available options
./install/editors.sh --neovim-only # Install only Neovim
./setup.sh --stow-only            # Only apply configurations
```

## 🛡️ Security

- Scripts check for root privileges and refuse to run as root
- Proper file permissions are set automatically
- All downloads are verified and use secure connections
- Existing configurations are backed up before changes

## 💡 Benefits

- **🚀 Fast Setup**: One command gets you a complete dev environment
- **🔧 Modular**: Install only what you need
- **🔄 Reproducible**: Same setup across all machines
- **📦 Latest Versions**: Always installs current stable releases
- **🛠️ Maintainable**: Easy to update and customize
- **📋 Well-Documented**: Clear instructions and help options
