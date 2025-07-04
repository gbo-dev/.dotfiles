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

# Install Neovim latest stable
install_neovim() {
    log_info "Installing Neovim..."

    if command_exists nvim; then
        local current_version
        current_version=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_info "Neovim $current_version is already installed"

        read -p "Do you want to update to the latest version? [y/N]: " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_success "Keeping current Neovim installation"
            return 0
        fi
    fi

    local temp_dir
    temp_dir=$(mktemp -d)

    log_info "Downloading latest Neovim release..."
    if curl -L -o "$temp_dir/nvim-linux-x86_64.tar.gz" \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"; then

        log_info "Installing Neovim to /opt/nvim..."
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf "$temp_dir/nvim-linux-x86_64.tar.gz"
        sudo mv /opt/nvim-linux-x86_64 /opt/nvim

        # Create symlink in /usr/local/bin
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

        # Clean up
        rm -rf "$temp_dir"

        log_success "Neovim installed successfully"
        log_info "Version: $(nvim --version | head -n1)"
    else
        log_error "Failed to download Neovim"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Install Zed editor
install_zed() {
    log_info "Installing Zed editor..."

    if command_exists zed; then
        log_success "Zed is already installed"
        return 0
    fi

    # Add Zed repository and install
    log_info "Adding Zed repository..."
    curl -f https://zed.dev/install.sh | sh

    if command_exists zed; then
        log_success "Zed installed successfully"
    else
        log_error "Failed to install Zed"
        return 1
    fi
}

# Install Visual Studio Code
install_vscode() {
    log_info "Installing Visual Studio Code..."

    if command_exists code; then
        log_success "VS Code is already installed"
        return 0
    fi

    # Add Microsoft GPG key and repository
    log_info "Adding Microsoft repository..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

    # Update package cache and install
    log_info "Updating package cache..."
    sudo apt update

    log_info "Installing VS Code..."
    if sudo apt install -y code; then
        log_success "VS Code installed successfully"

        # Clean up GPG file
        rm -f packages.microsoft.gpg
    else
        log_error "Failed to install VS Code"
        rm -f packages.microsoft.gpg
        return 1
    fi
}

# Install editor dependencies
install_editor_dependencies() {
    log_info "Installing editor dependencies..."

    local dependencies=(
        "git"
        "curl"
        "wget"
        "build-essential"
        "python3"
        "python3-pip"
        "nodejs"
        "npm"
        "ripgrep"
        "fd-find"
        "universal-ctags"
        "silversearcher-ag"
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

# Setup language servers for better editor experience
install_language_servers() {
    log_info "Installing language servers..."

    # Install Node.js language servers
    if command_exists npm; then
        local npm_packages=(
            "typescript-language-server"
            "bash-language-server"
            "vscode-langservers-extracted"
            "@tailwindcss/language-server"
            "yaml-language-server"
        )

        for package in "${npm_packages[@]}"; do
            if ! npm list -g "$package" &> /dev/null; then
                log_info "Installing $package..."
                sudo npm install -g "$package"
            fi
        done
        log_success "Node.js language servers installed"
    fi

    # Install Python language servers
    if command_exists pip3; then
        local python_packages=(
            "python-lsp-server"
            "pylsp-mypy"
            "python-lsp-black"
            "pylsp-rope"
        )

        for package in "${python_packages[@]}"; do
            if ! pip3 show "$package" &> /dev/null; then
                log_info "Installing $package..."
                pip3 install --user "$package"
            fi
        done
        log_success "Python language servers installed"
    fi

    # Install Rust analyzer if Rust is available
    if command_exists rustup; then
        log_info "Installing rust-analyzer..."
        rustup component add rust-analyzer
        log_success "Rust analyzer installed"
    fi

    # Install Go language server if Go is available
    if command_exists go; then
        log_info "Installing gopls..."
        go install golang.org/x/tools/gopls@latest
        log_success "Go language server installed"
    fi
}

# Main installation function
main() {
    log_info "Starting editors installation..."

    # Update package lists
    sudo apt update

    # Install dependencies first
    install_editor_dependencies

    # Install editors
    local failed_editors=()

    if ! install_neovim; then
        failed_editors+=("Neovim")
    fi

    if ! install_zed; then
        failed_editors+=("Zed")
    fi

    if ! install_vscode; then
        failed_editors+=("VS Code")
    fi

    # Install language servers for better development experience
    install_language_servers

    # Report results
    if [[ ${#failed_editors[@]} -eq 0 ]]; then
        log_success "All editors installed successfully!"
    else
        log_warning "Some editors failed to install: ${failed_editors[*]}"
    fi

    # Print post-installation info
    echo
    log_info "Post-installation notes:"
    echo "- Neovim config will be applied when you stow the dotfiles"
    echo "- Zed config will be applied when you stow the dotfiles"
    echo "- VS Code extensions can be installed via the editor or CLI"
    echo "- Language servers are installed for better development experience"
    echo
    log_info "Editor versions installed:"
    if command_exists nvim; then
        echo "  Neovim: $(nvim --version | head -n1 | cut -d' ' -f2)"
    fi
    if command_exists zed; then
        echo "  Zed: $(zed --version 2>/dev/null || echo "installed")"
    fi
    if command_exists code; then
        echo "  VS Code: $(code --version | head -n1)"
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h       Show this help message"
        echo "  --neovim-only    Install only Neovim"
        echo "  --zed-only       Install only Zed"
        echo "  --vscode-only    Install only VS Code"
        echo "  --deps-only      Install only dependencies"
        echo "  --lsp-only       Install only language servers"
        exit 0
        ;;
    --neovim-only)
        install_editor_dependencies
        install_neovim
        ;;
    --zed-only)
        install_editor_dependencies
        install_zed
        ;;
    --vscode-only)
        install_editor_dependencies
        install_vscode
        ;;
    --deps-only)
        install_editor_dependencies
        ;;
    --lsp-only)
        install_language_servers
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
