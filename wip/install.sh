#!/usr/bin/env bash

# Dotfiles Installation Script
# A simple and elegant solution for automated Linux development environment setup
# Supports x86_64 and ARM64 architectures

set -euo pipefail

# Script directory and library path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source common utilities
if [[ -f "$LIB_DIR/common.sh" ]]; then
    # shellcheck source=lib/common.sh
    source "$LIB_DIR/common.sh"
else
    echo "ERROR: Required library file not found: $LIB_DIR/common.sh"
    exit 1
fi

# Global configuration
export INTERACTIVE_MODE="${INTERACTIVE_MODE:-false}"
export DEBUG="${DEBUG:-false}"
TEMP_DIR="/tmp/dotfiles-install-$$"

# Skip packages functionality
declare -a SKIP_PACKAGES=()

# Installation components
INSTALL_PREREQUISITES=true
INSTALL_PACKAGES=true
INSTALL_EDITORS=true
INSTALL_DEVELOPMENT=true
INSTALL_TERMINALS=true
SETUP_DOTFILES=true

# Setup cleanup
setup_cleanup "$TEMP_DIR"

# Check if package should be skipped
should_skip() {
    local package="$1"
    for skip_pkg in "${SKIP_PACKAGES[@]}"; do
        if [[ "$skip_pkg" == "$package" ]]; then
            log_info "Skipping $package (requested via --skip)"
            return 0
        fi
    done
    return 1
}

# Show banner
show_banner() {
    print_section "Dotfiles Installation"
    echo "Platform: $(get_platform) $(get_architecture)"
    echo "Mode: $(if is_interactive; then echo "Interactive"; else echo "Automatic"; fi)"
    echo "Target: Complete development environment setup"
    echo
}

# Install basic prerequisites
install_prerequisites() {
    if [[ "$INSTALL_PREREQUISITES" != "true" ]]; then
        return 0
    fi

    print_section "Installing Prerequisites"

    local packages=("make" "git" "curl" "build-essential" "zsh" "stow")
    local missing_packages=()

    # Check which packages are missing
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        log_success "All prerequisites are already installed"
        return 0
    fi

    log_info "Missing packages: ${missing_packages[*]}"
    update_system

    for package in "${missing_packages[@]}"; do
        install_package "$package"
    done

    log_success "Prerequisites installed successfully"
}

# Install system packages from packages.list
install_system_packages() {
    if [[ "$INSTALL_PACKAGES" != "true" ]]; then
        return 0
    fi

    print_section "Installing System Packages"

    local packages_file="$SCRIPT_DIR/packages.list"
    if [[ ! -f "$packages_file" ]]; then
        log_warning "Packages file not found: $packages_file"
        return 0
    fi

    local packages=()
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            packages+=("$line")
        fi
    done < "$packages_file"

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warning "No packages found in $packages_file"
        return 0
    fi

    local to_install=()
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            to_install+=("$package")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All system packages are already installed"
        return 0
    fi

    log_info "Installing ${#to_install[@]} packages..."
    for package in "${to_install[@]}"; do
        install_package "$package"
    done

    # Setup alternatives for common renamed packages
    setup_package_alternatives

    log_success "System packages installed successfully"
}

# Setup alternatives for renamed packages
setup_package_alternatives() {
    # fd-find -> fd
    if command_exists fdfind && ! command_exists fd; then
        log_info "Setting up fd alternative for fdfind..."
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi

    # batcat -> bat
    if command_exists batcat && ! command_exists bat; then
        log_info "Setting up bat alternative for batcat..."
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    fi
}

# Install editors
install_editors() {
    if [[ "$INSTALL_EDITORS" != "true" ]]; then
        return 0
    fi

    print_section "Installing Editors"

    # Always install Neovim (unless skipped)
    if ! should_skip "neovim"; then
        install_neovim
    fi

    # Always install VS Code (unless skipped)
    if ! should_skip "vscode"; then
        install_vscode
    fi

    # Optional editors in interactive mode
    if is_interactive; then
        if ! should_skip "zed" && ask_confirmation "Install Zed editor?" "Y"; then
            install_zed
        fi
    else
        # Non-interactive: install Zed by default (unless skipped)
        if ! should_skip "zed"; then
            install_zed
        fi
    fi

    log_success "Editors installation completed"
}

# Install Neovim latest stable
install_neovim() {
    if command_exists nvim; then
        log_success "Neovim is already installed"
        return 0
    fi

    log_info "Installing Neovim latest stable..."

    local platform arch
    platform=$(get_platform)
    arch=$(get_architecture)

    if [[ "$platform" == "linux" ]]; then
        local temp_file="$TEMP_DIR/nvim-linux-x86_64.tar.gz"
        ensure_directory "$TEMP_DIR"

        if [[ "$arch" == "x86_64" ]]; then
            download_file \
                "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
                "$temp_file" \
                "Neovim"
        else
            log_error "Neovim: No pre-built binary for $arch, using system package"
            install_package "neovim"
            return
        fi

        # Extract and install
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf "$temp_file"

        # Add to PATH in shell configuration
        add_to_path "/opt/nvim-linux-x86_64/bin" "Neovim"

        # Create symlink for immediate use
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

        log_success "Neovim installed successfully"
    else
        install_package "neovim"
    fi
}

# Install Zed editor
install_zed() {
    if command_exists zed; then
        log_success "Zed is already installed"
        return 0
    fi

    log_info "Installing Zed editor..."

    local platform arch
    platform=$(get_platform)
    arch=$(get_architecture)

    if [[ "$platform" == "linux" ]]; then
        # Use Zed's installation script
        curl -f https://zed.dev/install.sh | sh
        log_success "Zed installed successfully"
    else
        log_warning "Zed installation not supported on $platform"
    fi
}

# Install VS Code
install_vscode() {
    if command_exists code; then
        log_success "VS Code is already installed"
        return 0
    fi

    log_info "Installing VS Code..."

    local platform
    platform=$(get_platform)

    if [[ "$platform" == "linux" ]]; then
        # Add Microsoft GPG key and repository
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

        sudo apt update
        install_package "code"
        log_success "VS Code installed successfully"
    else
        install_package "visual-studio-code"
    fi
}

# Install development tools
install_development_tools() {
    if [[ "$INSTALL_DEVELOPMENT" != "true" ]]; then
        return 0
    fi

    print_section "Installing Development Tools"

    # Always install Docker and Node.js (unless skipped)
    if ! should_skip "docker"; then
        install_docker
    fi
    if ! should_skip "nodejs"; then
        install_nodejs
    fi

    # Optional tools in interactive mode
    if is_interactive; then
        if ! should_skip "rust" && ask_confirmation "Install Rust toolchain?" "Y"; then
            install_rust
        fi

        if ! should_skip "go" && ask_confirmation "Install Go toolchain?" "Y"; then
            install_go
        fi

        if ! should_skip "databases" && ask_confirmation "Install database clients (PostgreSQL, SQLite)?" "Y"; then
            install_database_clients
        fi
    else
        # Non-interactive: install Rust and Go by default (unless skipped)
        if ! should_skip "rust"; then
            install_rust
        fi
        if ! should_skip "go"; then
            install_go
        fi
        if ! should_skip "databases"; then
            install_database_clients
        fi
    fi

    # Always install additional dev tools (unless skipped)
    if ! should_skip "devtools"; then
        install_additional_dev_tools
    fi

    log_success "Development tools installation completed"
}

# Install Docker
install_docker() {
    if command_exists docker; then
        log_success "Docker is already installed"
        return 0
    fi

    log_info "Installing Docker..."

    # Add Docker repository
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    log_success "Docker installed successfully"
    log_info "Log out and back in for docker group changes to take effect"
}

# Install Node.js via nvm
install_nodejs() {
    log_info "Installing Node.js via nvm..."

    # Check if nvm is already installed
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        log_success "nvm is already installed"
        # shellcheck source=/dev/null
        source "$HOME/.nvm/nvm.sh"
    else
        # Install nvm
        log_info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

        # Source nvm
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # Install latest LTS Node.js
    if ! command_exists node; then
        log_info "Installing latest LTS Node.js..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
    fi

    log_success "Node.js installed successfully"
}

# Install Rust
install_rust() {
    if command_exists rustc; then
        log_success "Rust is already installed"
        return 0
    fi

    log_info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # Add to PATH
    add_to_path "\$HOME/.cargo/bin" "Rust/Cargo"

    log_success "Rust installed successfully"
}

# Install Go
install_go() {
    if command_exists go; then
        log_success "Go is already installed"
        return 0
    fi

    log_info "Installing Go..."

    local arch version
    arch=$(get_architecture)
    version=$(get_latest_github_release "golang/go" | sed 's/^go//')

    if [[ -z "$version" ]]; then
        log_warning "Could not determine latest Go version, using v1.21.0"
        version="1.21.0"
    fi

    local temp_file="$TEMP_DIR/go.tar.gz"
    ensure_directory "$TEMP_DIR"

    download_file \
        "https://go.dev/dl/go${version}.linux-${arch}.tar.gz" \
        "$temp_file" \
        "Go $version"

    # Install Go
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$temp_file"

    # Add to PATH
    add_to_path "/usr/local/go/bin" "Go"

    log_success "Go installed successfully"
}

# Install database clients
install_database_clients() {
    log_info "Installing database clients (PostgreSQL, SQLite)..."

    local databases=("sqlite3" "postgresql-client")
    for db in "${databases[@]}"; do
        if ! is_package_installed "$db"; then
            install_package "$db"
        fi
    done

    log_success "Database clients installed (PostgreSQL, SQLite)"
}

# Install additional development tools
install_additional_dev_tools() {
    log_info "Installing additional development tools..."

    local tools=("httpie" "shellcheck" "imagemagick" "ffmpeg" "tldr")
    for tool in "${tools[@]}"; do
        if ! is_package_installed "$tool"; then
            install_package "$tool"
        fi
    done

    log_success "Additional development tools installed"
}

# Install terminal applications
install_terminals() {
    if [[ "$INSTALL_TERMINALS" != "true" ]]; then
        return 0
    fi

    print_section "Installing Terminals"

    # Always install Nerd Fonts (unless skipped)
    if ! should_skip "fonts"; then
        install_nerd_fonts
    fi

    # Always try to install Ghostty (unless skipped)
    if ! should_skip "ghostty"; then
        install_ghostty
    fi

    log_success "Terminal applications installation completed"
}

# Install Nerd Fonts
install_nerd_fonts() {
    log_info "Installing Nerd Fonts..."

    local fonts_dir="$HOME/.local/share/fonts"
    ensure_directory "$fonts_dir"

    local fonts=("AdwaitaMono" "JetBrainsMono")
    for font in "${fonts[@]}"; do
        if [[ ! -d "$fonts_dir/${font}NerdFont" ]]; then
            log_info "Installing $font Nerd Font..."
            local temp_file="$TEMP_DIR/${font}.zip"
            ensure_directory "$TEMP_DIR"

            download_file \
                "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" \
                "$temp_file" \
                "$font Nerd Font"

            local font_dir="$fonts_dir/${font}NerdFont"
            ensure_directory "$font_dir"
            unzip -q "$temp_file" -d "$font_dir"
        fi
    done

    # Refresh font cache
    if command_exists fc-cache; then
        fc-cache -fv
    fi

    log_success "Nerd Fonts installed"
}

# Install Ghostty terminal
install_ghostty() {
    if command_exists ghostty; then
        log_success "Ghostty is already installed"
        return 0
    fi

    log_info "Installing Ghostty terminal..."

    local platform arch
    platform=$(get_platform)
    arch=$(get_architecture)

    if [[ "$platform" == "linux" && "$arch" == "x86_64" ]]; then
        # Check for available releases
        local temp_file="$TEMP_DIR/ghostty.tar.gz"
        ensure_directory "$TEMP_DIR"

        # Try to download from GitHub releases
        if download_file \
            "https://github.com/ghostty-org/ghostty/releases/latest/download/ghostty-linux-x86_64.tar.gz" \
            "$temp_file" \
            "Ghostty"; then

            # Extract and install
            local install_dir="/opt/ghostty"
            sudo rm -rf "$install_dir"
            sudo mkdir -p "$install_dir"
            sudo tar -xzf "$temp_file" -C "$install_dir" --strip-components=1

            # Create symlink
            sudo ln -sf "$install_dir/bin/ghostty" /usr/local/bin/ghostty

            log_success "Ghostty installed successfully"
        else
            log_warning "Could not install Ghostty: no pre-built binary available"
        fi
    else
        log_warning "Ghostty installation not supported on $platform $arch"
    fi
}

# Setup dotfiles with stow
setup_dotfiles() {
    if [[ "$SETUP_DOTFILES" != "true" ]]; then
        return 0
    fi

    print_section "Setting Up Dotfiles"

    # Install Oh My Zsh first
    install_oh_my_zsh

    # Setup dotfiles with stow
    apply_dotfiles

    # Setup tmux plugin manager
    setup_tmux_plugins

    # Set zsh as default shell
    set_default_shell

    log_success "Dotfiles setup completed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh is already installed"
        return 0
    fi

    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Install zsh-autosuggestions
    local autosuggestions_dir="$HOME/.zsh/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        ensure_directory "$HOME/.zsh"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
    fi

    log_success "Oh My Zsh installed"
}

# Apply dotfiles with stow
apply_dotfiles() {
    log_info "Applying dotfile configurations..."

    local configs=("nvim" "tmux" "zsh" "ghostty" "zed" "alacritty" "kitty")
    local skipped_configs=()
    local applied_configs=()
    local adopted_configs=()
    local failed_configs=()

    for config in "${configs[@]}"; do
        # Skip configurations for skipped programs
        local should_skip_config=false
        case "$config" in
            "nvim")
                if should_skip "neovim"; then
                    should_skip_config=true
                    skipped_configs+=("$config")
                fi
                ;;
            "zed")
                if should_skip "zed"; then
                    should_skip_config=true
                    skipped_configs+=("$config")
                fi
                ;;
            "ghostty")
                if should_skip "ghostty"; then
                    should_skip_config=true
                    skipped_configs+=("$config")
                fi
                ;;
        esac

        if [[ "$should_skip_config" == "true" ]]; then
            log_info "Skipping $config configuration (program was skipped)"
            continue
        fi

        if [[ -d "$SCRIPT_DIR/$config" ]]; then
            log_info "Applying $config configuration..."
            if stow "$config" -d "$SCRIPT_DIR" -t "$HOME" 2>/dev/null; then
                log_success "$config configuration applied"
                applied_configs+=("$config")
            else
                log_warning "Conflicts detected for $config configuration"
                log_info "Attempting to adopt existing $config files..."
                if stow "$config" -d "$SCRIPT_DIR" -t "$HOME" --adopt 2>/dev/null; then
                    log_success "$config configuration adopted (existing files preserved)"
                    adopted_configs+=("$config")
                else
                    log_warning "Could not apply $config configuration - continuing anyway"
                    failed_configs+=("$config")
                fi
            fi
        else
            log_debug "$config directory not found, skipping"
        fi
    done

    # Show summary
    echo
    log_info "Configuration Summary:"
    if [[ ${#applied_configs[@]} -gt 0 ]]; then
        echo "  ✓ Applied: ${applied_configs[*]}"
    fi
    if [[ ${#adopted_configs[@]} -gt 0 ]]; then
        echo "  🔄 Adopted: ${adopted_configs[*]} (existing files preserved)"
    fi
    if [[ ${#skipped_configs[@]} -gt 0 ]]; then
        echo "  ⏭️  Skipped: ${skipped_configs[*]} (programs not installed)"
    fi
    if [[ ${#failed_configs[@]} -gt 0 ]]; then
        echo "  ❌ Failed: ${failed_configs[*]} (manual intervention needed)"
    fi

    log_success "Dotfile configurations completed"
}

# Setup tmux plugin manager
setup_tmux_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_info "Remember to press prefix + I in tmux to install plugins"
    fi
}

# Set zsh as default shell
set_default_shell() {
    if ! command_exists zsh; then
        log_warning "Zsh not found, skipping shell setup"
        return 0
    fi

    local current_shell zsh_path
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    zsh_path=$(which zsh)

    if [[ "$current_shell" != "$zsh_path" ]]; then
        log_info "Setting zsh as default shell..."
        chsh -s "$zsh_path"
        log_success "Default shell changed to zsh"
    fi
}

# Print post-installation instructions
show_completion() {
    print_section "Installation Complete!"

    echo "Your development environment is ready!"
    echo
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Open tmux and press prefix + I to install plugins"
    echo "  3. Open Neovim to trigger plugin installation"
    echo "  4. Log out and back in for Docker group changes"
    echo

    local installed_tools=()
    command_exists nvim && installed_tools+=("Neovim")
    command_exists zed && installed_tools+=("Zed")
    command_exists code && installed_tools+=("VS Code")
    command_exists docker && installed_tools+=("Docker")
    command_exists rustc && installed_tools+=("Rust")
    command_exists go && installed_tools+=("Go")
    command_exists node && installed_tools+=("Node.js")
    command_exists ghostty && installed_tools+=("Ghostty")

    if [[ ${#installed_tools[@]} -gt 0 ]]; then
        print_summary "${installed_tools[@]}"
    fi

    echo "Configuration files:"
    echo "  Neovim: ~/.config/nvim"
    echo "  Tmux: ~/.config/tmux"
    echo "  Zsh: ~/.zshrc"
    echo "  Ghostty: ~/.config/ghostty"
    echo
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --interactive|-i)
                export INTERACTIVE_MODE=true
                ;;
            --debug)
                export DEBUG=true
                ;;
            --skip)
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                    SKIP_PACKAGES+=("$1")
                    shift
                done
                continue
                ;;
            --no-prerequisites)
                INSTALL_PREREQUISITES=false
                ;;
            --no-packages)
                INSTALL_PACKAGES=false
                ;;
            --no-editors)
                INSTALL_EDITORS=false
                ;;
            --no-development)
                INSTALL_DEVELOPMENT=false
                ;;
            --no-terminals)
                INSTALL_TERMINALS=false
                ;;
            --no-dotfiles)
                SETUP_DOTFILES=false
                ;;
            --minimal)
                INSTALL_DEVELOPMENT=false
                INSTALL_TERMINALS=false
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
}

# Show help
show_help() {
    cat << EOF
Dotfiles Installation Script
===========================

Usage: $0 [options]

Options:
  --help, -h           Show this help message
  --interactive, -i    Enable interactive mode (ask before installing optional components)
  --debug              Enable debug output
  --minimal            Install only essential tools (skip development and terminal tools)
  --skip <packages>    Skip specific packages (e.g., --skip zed neovim docker)

Skip specific components:
  --no-prerequisites   Skip prerequisites installation
  --no-packages        Skip system packages installation
  --no-editors         Skip editors installation
  --no-development     Skip development tools installation
  --no-terminals       Skip terminal applications installation
  --no-dotfiles        Skip dotfiles setup

Examples:
  ./install.sh                   # Install everything with defaults
  ./install.sh --interactive     # Install with interactive prompts
  ./install.sh --minimal         # Install only essential tools
  ./install.sh --no-development  # Skip development tools
  ./install.sh --skip zed neovim # Skip specific packages
  ./install.sh --skip docker go rust # Skip specific development tools


What gets installed:
  Prerequisites: make, git, curl, build-essential, zsh, stow
  System packages: ripgrep, fzf, bat, fd-find, tmux, htop, etc.
  Editors: Neovim (always), VS Code (always), Zed (default)
  Development: Docker, Node.js (always), Rust, Go (default)
  Databases: PostgreSQL client, SQLite
  Dev tools: httpie, shellcheck, imagemagick, ffmpeg
  Terminals: Nerd Fonts, Ghostty
  Dotfiles: All configurations applied with GNU Stow

Configuration handling:
  - Skipped programs automatically skip their configurations
  - Conflicts are resolved by adopting existing files (preserves your settings)
  - Script continues even if some configurations fail

Packages you can skip:
  neovim, vscode, zed, docker, nodejs, rust, go, databases, devtools, fonts, ghostty

EOF
}

# Main installation function
main() {
    show_banner

    # System checks
    check_root
    check_system

    # Show system info in debug mode
    if [[ "$DEBUG" == "true" ]]; then
        log_debug "System Information:"
        get_system_info | while IFS= read -r line; do
            log_debug "$line"
        done
    fi

    # Run installation phases
    install_prerequisites
    install_system_packages
    install_editors
    install_development_tools
    install_terminals
    setup_dotfiles

    show_completion
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi
