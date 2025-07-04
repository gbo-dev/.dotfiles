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

# Add path to zsh configuration if not already present
add_to_zsh_path() {
    local path_to_add="$1"
    local description="$2"
    local zshrc_path="$HOME/.zshrc"

    # Check if path is already in current PATH
    if echo "$PATH" | grep -q "$path_to_add"; then
        log_success "$description is already in PATH"
        return 0
    fi

    log_info "Adding $description to PATH in zsh configuration..."

    # Check if .zshrc exists
    if [[ -f "$zshrc_path" ]]; then
        # Check if path is already in .zshrc
        if ! grep -q "$path_to_add" "$zshrc_path"; then
            # Add path to .zshrc
            echo "" >> "$zshrc_path"
            echo "# $description" >> "$zshrc_path"
            echo "export PATH=\"$path_to_add:\$PATH\"" >> "$zshrc_path"
            log_success "Added $description to PATH in ~/.zshrc"
            log_info "Restart your terminal or run 'source ~/.zshrc' to use $description"
        else
            log_success "$description path already configured in ~/.zshrc"
        fi
    else
        log_warning "~/.zshrc not found. Add $path_to_add to your PATH manually"
    fi
}

# Install Docker
install_docker() {
    log_info "Installing Docker..."

    if command_exists docker; then
        log_success "Docker is already installed"
        return 0
    fi

    # Add Docker's official GPG key
    log_info "Adding Docker repository..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    log_success "Docker installed successfully"
    log_info "You may need to log out and back in for docker group changes to take effect"
}

# Install Rust
install_rust() {
    log_info "Installing Rust..."

    if command_exists rustc; then
        log_success "Rust is already installed"
        return 0
    fi

    log_info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # Source cargo env
    source "$HOME/.cargo/env"

    # Add Rust/Cargo to PATH
    add_to_zsh_path "\$HOME/.cargo/bin" "Rust/Cargo"

    log_success "Rust installed successfully"
}

# Install Go
install_go() {
    log_info "Installing Go..."

    if command_exists go; then
        log_success "Go is already installed"
        return 0
    fi

    local temp_dir
    temp_dir=$(mktemp -d)

    # Get latest Go version
    local go_version
    go_version=$(curl -s https://go.dev/VERSION?m=text | head -n1)

    log_info "Downloading Go $go_version..."
    curl -L -o "$temp_dir/go.tar.gz" "https://go.dev/dl/${go_version}.linux-amd64.tar.gz"

    # Remove existing Go installation and install new one
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$temp_dir/go.tar.gz"

    # Clean up
    rm -rf "$temp_dir"

    log_success "Go installed successfully"

    # Add Go to PATH
    add_to_zsh_path "/usr/local/go/bin" "Go"
}

# Install Node.js via nvm
install_nodejs() {
    log_info "Installing Node.js via nvm..."

    # Check if nvm is already installed
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        log_info "nvm is already installed"
        source "$HOME/.nvm/nvm.sh"

        if command_exists node; then
            local current_version
            current_version=$(node --version)
            log_success "Node.js $current_version is already installed"
            return 0
        fi
    else
        # Install nvm
        log_info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

        # Source nvm to use it immediately
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        log_success "nvm installed successfully"
    fi

    # Install latest LTS Node.js
    log_info "Installing latest LTS Node.js..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*

    # Install global npm packages
    log_info "Installing global npm packages..."
    local npm_packages=(
        "yarn"
        "typescript"
        "ts-node"
        "eslint"
        "prettier"
        "create-react-app"
        "http-server"
    )

    for package in "${npm_packages[@]}"; do
        log_info "Installing $package..."
        npm install -g "$package"
    done

    log_success "Node.js and global packages installed successfully"
}

# Install development databases
install_databases() {
    log_info "Installing development databases..."

    local databases=(
        "sqlite3"
        "postgresql-client"
    )

    local to_install=()
    for db in "${databases[@]}"; do
        if ! dpkg -l "$db" &> /dev/null; then
            to_install+=("$db")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing database clients: ${to_install[*]}"
        sudo apt install -y "${to_install[@]}"
        log_success "Database clients installed"
    else
        log_success "All database clients are already installed"
    fi
}

# Install additional development tools
install_dev_tools() {
    log_info "Installing additional development tools..."

    local dev_tools=(
        "httpie"
        "tree"
        "tldr"
        "shellcheck"
        "imagemagick"
        "ffmpeg"
    )

    local to_install=()
    for tool in "${dev_tools[@]}"; do
        if ! dpkg -l "$tool" &> /dev/null; then
            to_install+=("$tool")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing development tools: ${to_install[*]}"
        sudo apt install -y "${to_install[@]}"
        log_success "Development tools installed"
    else
        log_success "All development tools are already installed"
    fi
}

# Main installation function
main() {
    log_info "Starting development tools installation..."

    # Update package lists
    sudo apt update

    # Install development tools and languages
    local failed_installs=()

    if ! install_docker; then
        failed_installs+=("Docker")
    fi

    if ! install_rust; then
        failed_installs+=("Rust")
    fi

    if ! install_go; then
        failed_installs+=("Go")
    fi

    if ! install_nodejs; then
        failed_installs+=("Node.js")
    fi

    install_databases
    install_dev_tools

    # Report results
    if [[ ${#failed_installs[@]} -eq 0 ]]; then
        log_success "All development tools installed successfully!"
    else
        log_warning "Some tools failed to install: ${failed_installs[*]}"
    fi

    # Print post-installation info
    echo
    log_info "Post-installation notes:"
    echo "- Add /usr/local/go/bin to your PATH for Go"
    echo "- Source ~/.cargo/env for Rust (or restart terminal)"
    echo "- Log out and back in for Docker group changes to take effect"
    echo
    log_info "Development tools installed:"
    if command_exists docker; then
        echo "  Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    fi
    if command_exists rustc; then
        echo "  Rust: $(rustc --version | cut -d' ' -f2)"
    fi
    if command_exists go; then
        echo "  Go: $(go version | cut -d' ' -f3)"
    fi
    if command_exists node; then
        echo "  Node.js: $(node --version)"
    fi
    if command_exists python3; then
        echo "  Python: $(python3 --version | cut -d' ' -f2)"
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h       Show this help message"
        echo "  --docker-only    Install only Docker"
        echo "  --rust-only      Install only Rust"
        echo "  --go-only        Install only Go"
        echo "  --node-only      Install only Node.js"
        echo "  --python-only    Install only Python tools"
        echo "  --db-only        Install only database clients"
        exit 0
        ;;
    --docker-only)
        install_docker
        ;;
    --rust-only)
        install_rust
        ;;
    --go-only)
        install_go
        ;;
    --node-only)
        install_nodejs
        ;;
    --db-only)
        install_databases
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
