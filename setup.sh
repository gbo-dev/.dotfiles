#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    local missing_tools=()

    # Check for required tools
    if ! command -v make &> /dev/null; then
        missing_tools+=("make")
    fi

    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi

    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install them first: sudo apt update && sudo apt install -y ${missing_tools[*]}"
        exit 1
    fi

    log_success "All prerequisites available"
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

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    log_success "System updated"
}

# Install base packages
install_base_packages() {
    log_info "Installing base packages from install file..."
    if [[ -f "$INSTALL_DIR/apt-packages.sh" ]]; then
        bash "$INSTALL_DIR/apt-packages.sh"
    else
        log_warning "apt-packages.sh not found, skipping base packages"
    fi
}

# Install editors
install_editors() {
    log_info "Installing editors (Neovim, Zed, VS Code)..."
    if [[ -f "$INSTALL_DIR/editors.sh" ]]; then
        bash "$INSTALL_DIR/editors.sh"
    else
        log_warning "editors.sh not found, skipping editors"
    fi
}

# Install terminals
install_terminals() {
    log_info "Installing terminal applications..."
    if [[ -f "$INSTALL_DIR/terminals.sh" ]]; then
        bash "$INSTALL_DIR/terminals.sh"
    else
        log_warning "terminals.sh not found, skipping terminals"
    fi
}

# Install development tools
install_development() {
    log_info "Installing additional development tools..."
    if [[ -f "$INSTALL_DIR/development.sh" ]]; then
        bash "$INSTALL_DIR/development.sh"
    else
        log_warning "development.sh not found, skipping development tools"
    fi
}

# Setup dotfiles with stow
setup_dotfiles() {
    log_info "Setting up dotfiles with stow..."

    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        log_error "Stow is not installed. Please install it first."
        return 1
    fi

    # Available configurations
    local configs=("nvim" "tmux" "zsh" "ghostty" "zed" "alacritty" "kitty")

    for config in "${configs[@]}"; do
        if [[ -d "$SCRIPT_DIR/$config" ]]; then
            log_info "Stowing $config configuration..."
            stow "$config" -d "$SCRIPT_DIR" -t "$HOME"
            log_success "$config configuration linked"
        else
            log_warning "$config directory not found, skipping"
        fi
    done
}

# Install oh-my-zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."

    local oh_my_zsh_dir="$HOME/.oh-my-zsh"

    if [[ -d "$oh_my_zsh_dir" ]]; then
        log_success "Oh My Zsh is already installed"
        return 0
    fi

    # Install Oh My Zsh
    log_info "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Install zsh-autosuggestions plugin
    local autosuggestions_dir="$HOME/.zsh/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        log_info "Installing zsh-autosuggestions plugin..."
        mkdir -p "$HOME/.zsh"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
        log_success "zsh-autosuggestions installed"
    else
        log_success "zsh-autosuggestions already installed"
    fi

    log_success "Oh My Zsh installation completed"
}

# Setup zsh as default shell
setup_zsh() {
    log_info "Setting up zsh as default shell..."

    if command -v zsh &> /dev/null; then
        local current_shell
        current_shell=$(getent passwd "$USER" | cut -d: -f7)
        local zsh_path
        zsh_path=$(which zsh)

        if [[ "$current_shell" != "$zsh_path" ]]; then
            log_info "Changing default shell to zsh..."
            chsh -s "$zsh_path"
            log_success "Default shell changed to zsh (restart terminal to take effect)"
        else
            log_success "Zsh is already the default shell"
        fi
    else
        log_warning "Zsh not found, skipping shell setup"
    fi
}

# Setup tmux plugin manager
setup_tmux() {
    log_info "Setting up tmux plugin manager..."

    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
        log_info "Remember to press prefix + I in tmux to install plugins"
    else
        log_success "TPM already installed"
    fi
}

# Set correct permissions
set_permissions() {
    log_info "Setting correct permissions..."
    chmod 700 "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -name "*.sh" -exec chmod 755 {} \;
    log_success "Permissions set"
}

# Print post-install instructions
print_instructions() {
    echo
    log_success "Setup completed successfully!"
    echo
    echo -e "${YELLOW}Post-installation steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Open tmux and press prefix + I to install tmux plugins"
    echo "3. Open neovim to trigger plugin installation"
    echo "4. Configure any editor-specific settings as needed"
    echo
    echo -e "${BLUE}Available configurations:${NC}"
    echo "- Neovim: ~/.config/nvim"
    echo "- Tmux: ~/.config/tmux"
    echo "- Zsh: ~/.zshrc"
    echo "- Ghostty: ~/.config/ghostty"
    echo "- Zed: ~/.config/zed"
    echo
    echo -e "${BLUE}Useful commands:${NC}"
    echo "- config: Quick access to configuration files (when zsh is loaded)"
    echo "- make install: Re-run installation scripts"
    echo "- make stow: Re-apply dotfile configurations"
}

# Main installation function
main() {
    log_info "Starting dotfiles setup for Linux..."
    echo

    check_prerequisites
    check_system
    check_root

    # Run installation steps
    update_system
    install_base_packages

    # Install and configure zsh early so other tools can use it
    install_oh_my_zsh
    setup_dotfiles
    setup_zsh

    # Continue with other installations
    install_editors
    install_terminals
    install_development
    setup_tmux
    set_permissions

    print_instructions
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --base-only    Install only base packages"
        echo "  --editors-only Install only editors"
        echo "  --stow-only    Only setup dotfiles (no package installation)"
        exit 0
        ;;
    --base-only)
        update_system
        install_base_packages
        ;;
    --editors-only)
        install_editors
        ;;
    --stow-only)
        install_oh_my_zsh
        setup_dotfiles
        setup_zsh
        setup_tmux
        set_permissions
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
