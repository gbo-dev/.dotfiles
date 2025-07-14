# Ansible Dotfiles Automation

This directory contains Ansible playbooks for automating the installation and configuration of dotfiles on Linux systems. It provides a cleaner, more maintainable alternative to shell scripts with better idempotency and error handling.

## Quick Start

```bash
# Navigate to the ansible directory
cd ~/.dotfiles/ansible

# Run the installation script (installs Ansible if needed)
./install.sh

# Or run specific modes
./install.sh --mode minimal      # Core packages only
./install.sh --mode development  # Full development setup
./install.sh --dry-run          # Test without making changes
```

## Features

- ✅ **Idempotent**: Safe to run multiple times
- ✅ **Modular**: Install only what you need
- ✅ **Cross-distribution**: Support for Debian/Ubuntu (more coming)
- ✅ **Backup**: Automatic backup of existing configurations
- ✅ **Error handling**: Graceful failure recovery
- ✅ **Dry run**: Test changes before applying

## Installation Modes

| Mode | Description | Includes |
|------|-------------|----------|
| `minimal` | Essential tools only | Core packages, zsh, stow, basic dotfiles |
| `standard` | Standard development setup | Minimal + CLI tools, editors |
| `full` | Complete installation | Standard + terminals, fonts, GUI apps |
| `development` | Full development environment | Full + Docker, Rust, Go, Node.js, databases |

## Directory Structure

```
ansible/
├── playbooks/           # Main playbooks
│   ├── main.yml        # Main orchestration playbook
│   ├── prerequisites.yml
│   ├── system-packages.yml
│   ├── editors.yml
│   ├── terminals.yml
│   ├── development.yml
│   └── dotfiles.yml
├── inventory/          # Host definitions
│   ├── hosts.yml       # Main inventory
│   └── group_vars/     # Variables by group
├── vars/               # Variable files
│   ├── packages.yml    # Package definitions
│   ├── editors.yml     # Editor configurations
│   └── development.yml # Development tool configs
├── ansible.cfg         # Ansible configuration
├── install.sh         # Installation script
└── README.md          # This file
```

## Installation Script Usage

The `install.sh` script handles Ansible installation and provides a simple interface:

### Basic Usage

```bash
# Full installation (default)
./install.sh

# Minimal installation
./install.sh --mode minimal

# Development setup
./install.sh --mode development

# Dry run (test without changes)
./install.sh --dry-run

# Verbose output
./install.sh --verbose
```

### Advanced Usage

```bash
# Install only specific components
./install.sh --tags "packages,editors"

# Skip development tools
./install.sh --skip-tags "development"

# Target remote host
./install.sh --target my-server

# Check dependencies only
./install.sh --check-deps

# List available hosts
./install.sh --list-hosts

# List available tags
./install.sh --list-tags
```

## Direct Ansible Usage

If you prefer to use Ansible directly:

```bash
# Install Ansible first
sudo apt install ansible  # or pip install ansible

# Run the main playbook
ansible-playbook -i inventory/hosts.yml playbooks/main.yml

# With specific mode
ansible-playbook -i inventory/hosts.yml playbooks/main.yml \
  --extra-vars "install_mode=development"

# Dry run
ansible-playbook -i inventory/hosts.yml playbooks/main.yml --check --diff

# Specific tags only
ansible-playbook -i inventory/hosts.yml playbooks/main.yml \
  --tags "packages,dotfiles"
```

## Available Tags

Use tags to run only specific parts of the installation:

- `always` - Prerequisites (always runs)
- `packages` - System package installation
- `editors` - Editor installation (Neovim, Zed, VS Code)
- `terminals` - Terminal applications and fonts
- `development` - Development tools (Docker, Rust, Go, Node.js)
- `dotfiles` - Dotfiles configuration with stow
- `stow` - Stow operations only
- `config` - Configuration tasks only

## Configuration

### Inventory Configuration

Edit `inventory/hosts.yml` to configure your target hosts:

```yaml
all:
  children:
    local:
      hosts:
        localhost:
          ansible_connection: local
```

### Variables

Customize installation by editing variables in:

- `inventory/group_vars/all.yml` - Global settings
- `inventory/group_vars/debian.yml` - Debian/Ubuntu specific
- `vars/packages.yml` - Package lists
- `vars/editors.yml` - Editor configurations
- `vars/development.yml` - Development tool settings

### Key Variables

```yaml
# Enable/disable components
editors:
  neovim:
    enabled: true
  zed:
    enabled: true
  vscode:
    enabled: true

development:
  docker:
    enabled: true
  rust:
    enabled: true
  nodejs:
    enabled: true

# Installation preferences
install_flags:
  minimal: false
  full: true
  development: true
  gui_applications: true
```

## What Gets Installed

### System Packages (packages tag)
- Core build tools (gcc, make, build-essential)
- CLI utilities (zsh, tmux, fzf, ripgrep, fd-find, bat, htop, tree)
- Development tools (git, curl, wget, unzip, stow)
- Optional tools (httpie, jq, shellcheck, imagemagick)

### Editors (editors tag)
- **Neovim** - Latest stable from GitHub releases
- **Zed** - Latest via official installer script
- **VS Code** - From Microsoft repository
- **Language servers** - TypeScript, Rust, Go, Python, Bash

### Terminals (terminals tag)
- **Ghostty** - Latest from GitHub releases
- **Fonts** - JetBrainsMono Nerd Font, Adwaita Mono
- System font packages

### Development Tools (development tag)
- **Docker** - From official Docker repository
- **Rust** - Via rustup with rust-analyzer
- **Go** - Latest official binary
- **Node.js** - Via NVM with global packages
- **Python** - System packages + pip tools
- **Database clients** - PostgreSQL, Redis, SQLite

### Dotfiles (dotfiles tag)
- Stow-based configuration management
- Oh My Zsh installation
- Zsh plugins (autosuggestions, syntax highlighting)
- Tmux Plugin Manager (TPM)
- Automatic backup of existing configs

## Remote Installation

To install on remote hosts:

1. Add your host to `inventory/hosts.yml`:

```yaml
all:
  children:
    remote_servers:
      hosts:
        my-server:
          ansible_host: 192.168.1.100
          ansible_user: username
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

2. Run with target:

```bash
./install.sh --target my-server
```

## Troubleshooting

### Common Issues

1. **Ansible not found**
   ```bash
   # Install Ansible manually
   sudo apt install ansible
   # Or use pip
   pip3 install --user ansible
   ```

2. **Permission denied**
   ```bash
   # Make sure you can sudo without password or use:
   ansible-playbook ... --ask-become-pass
   ```

3. **Stow conflicts**
   - Existing dotfiles will be backed up automatically
   - Check backup directory: `~/.dotfiles-backup-<timestamp>`

4. **Package installation fails**
   - Update package cache: `sudo apt update`
   - Check internet connectivity
   - Review specific package errors in output

### Debugging

```bash
# Verbose output
./install.sh --verbose

# Check syntax
ansible-playbook --syntax-check playbooks/main.yml

# List all tasks
ansible-playbook --list-tasks playbooks/main.yml

# Check variables
ansible-inventory --list -i inventory/hosts.yml
```

## Contributing

To add support for new tools or distributions:

1. Add package definitions to `vars/packages.yml`
2. Create or update playbook tasks
3. Add distribution-specific variables
4. Test with `--dry-run` first
5. Update documentation

## Comparison with Shell Scripts

| Feature | Shell Scripts | Ansible |
|---------|--------------|---------|
| Idempotency | Manual checking | Built-in |
| Error handling | Basic | Comprehensive |
| Rollback | Manual | Supported |
| Remote execution | SSH scripting | Native |
| Parallel execution | Limited | Built-in |
| Configuration management | Scripts | Declarative |
| Distribution support | Manual | Structured |
| Dry run | Custom implementation | Native |

## Migration from Shell Scripts

If you're migrating from the existing shell scripts:

1. Your existing Makefile commands still work
2. Run `./ansible/install.sh` instead of `./setup.sh`
3. Use tags for partial installations: `./install.sh --tags packages`
4. Configuration is now in YAML files instead of shell variables

The Ansible implementation provides the same functionality with better reliability and maintainability.