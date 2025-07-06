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

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Check if running on supported system
check_system() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_error "This script is designed for Linux systems only"
        exit 1
    fi

    if ! command -v apt &> /dev/null; then
        log_error "This script requires apt package manager (Debian/Ubuntu)"
        exit 1
    fi
}

# Install basic prerequisites
install_prerequisites() {
    log_info "Installing basic prerequisites..."

    local packages=("make" "git" "curl" "build-essential")
    local missing_packages=()

    # Check which packages are missing
    for package in "${packages[@]}"; do
        if ! dpkg -l "$package" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        log_success "All prerequisites are already installed"
        return 0
    fi

    log_info "Missing packages: ${missing_packages[*]}"
    log_info "Updating package lists..."
    sudo apt update

    log_info "Installing missing packages..."
    sudo apt install -y "${missing_packages[@]}"

    log_success "Prerequisites installed successfully"
}

# Install and configure zsh
install_zsh() {
    log_info "Installing and configuring zsh..."

    # Install zsh if not already installed
    if ! dpkg -l zsh &> /dev/null; then
        log_info "Installing zsh..."
        sudo apt install -y zsh
    else
        log_success "zsh is already installed"
    fi

    # Install stow if not already installed (needed for symlinking)
    if ! dpkg -l stow &> /dev/null; then
        log_info "Installing stow..."
        sudo apt install -y stow
    else
        log_success "stow is already installed"
    fi

    # Create backup of existing zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        log_info "Backing up existing .zshrc..."
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
    fi

    # Get the script directory (should be .dotfiles)
    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Symlink zsh configuration using stow
    if [[ -d "$dotfiles_dir/zsh" ]]; then
        log_info "Symlinking zsh configuration..."
        cd "$dotfiles_dir"
        stow zsh -t "$HOME" || {
            log_warning "Failed to stow zsh config, trying to remove conflicts..."
            # Remove conflicting files and try again
            rm -f "$HOME/.zshrc" "$HOME/.zsh_aliases" 2>/dev/null || true
            stow zsh -t "$HOME"
        }
        log_success "zsh configuration symlinked"
    else
        log_warning "zsh configuration directory not found at $dotfiles_dir/zsh"
    fi

    # Set zsh as default shell
    local zsh_path
    zsh_path=$(which zsh)
    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [[ "$current_shell" != "$zsh_path" ]]; then
        log_info "Setting zsh as default shell..."
        chsh -s "$zsh_path"
        log_success "Default shell changed to zsh (restart terminal to take effect)"
    else
        log_success "zsh is already the default shell"
    fi

    log_success "zsh installation and configuration completed"
}

# Verify installation
verify_prerequisites() {
    log_info "Verifying prerequisite installation..."

    local required_commands=("make" "git" "curl" "gcc")
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Some prerequisites are still missing: ${missing_commands[*]}"
        return 1
    fi

    log_success "All prerequisites verified and working"
}

# Print next steps
print_next_steps() {
    echo
    log_success "Prerequisites installation completed!"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Run the main setup script:"
    echo "   ./setup.sh"
    echo
    echo "2. Or use the Makefile:"
    echo "   make install"
    echo
    echo -e "${BLUE}What was installed:${NC}"
    echo "- make: Build automation tool"
    echo "- git: Version control system"
    echo "- curl: Data transfer tool"
    echo "- build-essential: Compilation tools (gcc, g++, make, etc.)"
    echo "- zsh: Z shell with configuration symlinked"
    echo "- stow: Symlink farm manager"
}

# Main function
main() {
    echo -e "${BLUE}Dotfiles Prerequisites Installer${NC}"
    echo "=================================="
    echo

    check_system
    check_root
    install_prerequisites
    install_zsh
    verify_prerequisites
    print_next_steps
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Prerequisites Installation Script"
        echo "================================="
        echo
        echo "This script installs the basic tools required for the dotfiles setup:"
        echo "- make (build automation)"
        echo "- git (version control)"
        echo "- curl (data transfer)"
        echo "- build-essential (compilation tools)"
        echo "- zsh (Z shell with configuration)"
        echo "- stow (symlink farm manager)"
        echo
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --verify       Only verify prerequisites (don't install)"
        echo
        echo "Run this script first, then run ./setup.sh for the main installation."
        exit 0
        ;;
    --verify)
        echo -e "${BLUE}Verifying Prerequisites${NC}"
        echo "======================="
        echo
        check_system
        verify_prerequisites
        echo
        if verify_prerequisites; then
            log_success "System is ready for dotfiles installation"
        else
            log_error "Prerequisites missing. Run this script without arguments to install them."
            exit 1
        fi
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
