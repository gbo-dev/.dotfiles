#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect system architecture
get_architecture() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
}

# Install Ghostty terminal
install_ghostty() {
    log_info "Installing Ghostty terminal..."

    if command_exists ghostty; then
        log_success "Ghostty is already installed"
        return 0
    fi

    local arch
    arch=$(get_architecture)
    local temp_dir
    temp_dir=$(mktemp -d)

    log_info "Detecting latest Ghostty release..."
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest | \
                 grep "browser_download_url.*linux.*$arch.*\.tar\.xz" | \
                 cut -d '"' -f 4)

    if [[ -z "$latest_url" ]]; then
        log_error "Could not find Ghostty release for architecture: $arch"
        rm -rf "$temp_dir"
        return 1
    fi

    log_info "Downloading Ghostty from: $latest_url"
    if curl -L -o "$temp_dir/ghostty.tar.xz" "$latest_url"; then
        log_info "Extracting Ghostty..."
        cd "$temp_dir"
        tar -xf ghostty.tar.xz

        # Find the extracted directory
        local ghostty_dir
        ghostty_dir=$(find . -name "ghostty-*" -type d | head -n1)

        if [[ -z "$ghostty_dir" ]]; then
            log_error "Could not find extracted Ghostty directory"
            rm -rf "$temp_dir"
            return 1
        fi

        log_info "Installing Ghostty to /opt/ghostty..."
        sudo rm -rf /opt/ghostty
        sudo mv "$ghostty_dir" /opt/ghostty

        # Create symlink in /usr/local/bin
        sudo ln -sf /opt/ghostty/bin/ghostty /usr/local/bin/ghostty

        # Install desktop file if it exists
        if [[ -f "/opt/ghostty/share/applications/ghostty.desktop" ]]; then
            log_info "Installing desktop file..."
            sudo cp /opt/ghostty/share/applications/ghostty.desktop /usr/share/applications/
            sudo update-desktop-database
        fi

        # Install icon if it exists
        if [[ -f "/opt/ghostty/share/icons/hicolor/256x256/apps/ghostty.png" ]]; then
            log_info "Installing application icon..."
            sudo mkdir -p /usr/share/icons/hicolor/256x256/apps/
            sudo cp /opt/ghostty/share/icons/hicolor/256x256/apps/ghostty.png /usr/share/icons/hicolor/256x256/apps/
            sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor/ 2>/dev/null || true
        fi

        # Clean up
        rm -rf "$temp_dir"

        log_success "Ghostty installed successfully"
        log_info "Version: $(ghostty --version 2>/dev/null || echo "installed")"
    else
        log_error "Failed to download Ghostty"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Install terminal dependencies
install_terminal_dependencies() {
    log_info "Installing terminal dependencies..."

    local dependencies=(
        "curl"
        "wget"
        "tar"
        "xz-utils"
        "desktop-file-utils"
        "gtk-update-icon-cache"
    )

    local to_install=()
    for dep in "${dependencies[@]}"; do
        if ! dpkg -l "$dep" &> /dev/null; then
            to_install+=("$dep")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing missing dependencies: ${to_install[*]}"
        sudo apt install -y "${to_install[@]}"
        log_success "Dependencies installed"
    else
        log_success "All dependencies are already installed"
    fi
}

# Install additional terminal tools
install_terminal_tools() {
    log_info "Installing additional terminal tools..."

    local tools=(
        "alacritty"      # Alternative terminal
        "kitty"          # Alternative terminal
        "terminator"     # Multi-pane terminal
        "screen"         # Terminal multiplexer
        "byobu"          # Enhanced screen/tmux
    )

    local optional_tools=()
    for tool in "${tools[@]}"; do
        if ! dpkg -l "$tool" &> /dev/null; then
            optional_tools+=("$tool")
        fi
    done

    if [[ ${#optional_tools[@]} -gt 0 ]]; then
        echo
        log_info "Optional terminal applications available:"
        printf '  %s\n' "${optional_tools[@]}"
        echo
        read -p "Do you want to install these optional terminal applications? [y/N]: " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installing optional terminal tools..."
            sudo apt install -y "${optional_tools[@]}"
            log_success "Optional terminal tools installed"
        else
            log_info "Skipping optional terminal tools"
        fi
    else
        log_success "All optional terminal tools are already installed"
    fi
}

# Setup terminal fonts
install_terminal_fonts() {
    log_info "Installing terminal fonts..."

    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"

    # Install Nerd Fonts for better terminal experience
    local temp_dir
    temp_dir=$(mktemp -d)

    log_info "Installing FiraCode Nerd Font..."
    if curl -L -o "$temp_dir/FiraCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"; then

        unzip -q "$temp_dir/FiraCode.zip" -d "$fonts_dir/FiraCode"
        log_success "FiraCode Nerd Font installed"
    else
        log_warning "Failed to download FiraCode Nerd Font"
    fi

    log_info "Installing JetBrainsMono Nerd Font..."
    if curl -L -o "$temp_dir/JetBrainsMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then

        unzip -q "$temp_dir/JetBrainsMono.zip" -d "$fonts_dir/JetBrainsMono"
        log_success "JetBrainsMono Nerd Font installed"
    else
        log_warning "Failed to download JetBrainsMono Nerd Font"
    fi

    # Update font cache
    fc-cache -fv &>/dev/null
    log_success "Font cache updated"

    # Clean up
    rm -rf "$temp_dir"
}

# Main installation function
main() {
    log_info "Starting terminal applications installation..."

    # Update package lists
    sudo apt update

    # Install dependencies first
    install_terminal_dependencies

    # Install Ghostty
    local failed_terminals=()

    if ! install_ghostty; then
        failed_terminals+=("Ghostty")
    fi

    # Install terminal fonts
    install_terminal_fonts

    # Install optional terminal tools
    install_terminal_tools

    # Report results
    if [[ ${#failed_terminals[@]} -eq 0 ]]; then
        log_success "All terminal applications installed successfully!"
    else
        log_warning "Some terminals failed to install: ${failed_terminals[*]}"
    fi

    # Print post-installation info
    echo
    log_info "Post-installation notes:"
    echo "- Ghostty config will be applied when you stow the dotfiles"
    echo "- Terminal fonts (FiraCode, JetBrainsMono) are installed in ~/.local/share/fonts"
    echo "- You may need to restart your desktop session for fonts to be available"
    echo "- Configure your terminal settings after stowing configs"
    echo
    log_info "Terminal applications installed:"
    if command_exists ghostty; then
        echo "  Ghostty: $(ghostty --version 2>/dev/null || echo "installed")"
    fi
    if command_exists alacritty; then
        echo "  Alacritty: $(alacritty --version | head -n1 | cut -d' ' -f2)"
    fi
    if command_exists kitty; then
        echo "  Kitty: $(kitty --version | cut -d' ' -f2)"
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h         Show this help message"
        echo "  --ghostty-only     Install only Ghostty"
        echo "  --fonts-only       Install only terminal fonts"
        echo "  --optional-only    Install only optional terminal tools"
        echo "  --deps-only        Install only dependencies"
        exit 0
        ;;
    --ghostty-only)
        install_terminal_dependencies
        install_ghostty
        ;;
    --fonts-only)
        install_terminal_fonts
        ;;
    --optional-only)
        install_terminal_tools
        ;;
    --deps-only)
        install_terminal_dependencies
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
