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

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.list"

# All packages are now read from packages.list file

# Install packages using apt
install_packages() {
    local packages=("$@")
    local failed_packages=()

    log_info "Installing packages: ${packages[*]}"

    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        if sudo apt install -y "$package"; then
            log_success "$package installed successfully"
        else
            log_warning "Failed to install $package"
            failed_packages+=("$package")
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warning "Failed to install: ${failed_packages[*]}"
        return 1
    fi

    return 0
}

# Check if package is already installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Filter out already installed packages
filter_installed_packages() {
    local packages=("$@")
    local to_install=()

    for package in "${packages[@]}"; do
        if is_package_installed "$package"; then
            log_success "$package is already installed"
        else
            to_install+=("$package")
        fi
    done

    echo "${to_install[@]}"
}

# Read packages from packages.list file if it exists
read_packages_file() {
    if [[ -f "$PACKAGES_FILE" ]]; then
        log_info "Reading packages from $PACKAGES_FILE"
        local file_packages=()
        while IFS= read -r line; do
            # Skip empty lines and comments
            if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
                file_packages+=("$line")
            fi
        done < "$PACKAGES_FILE"
        echo "${file_packages[@]}"
    else
        log_warning "Packages file not found: $PACKAGES_FILE"
        echo ""
    fi
}

# Main installation function
main() {
    log_info "Starting apt package installation..."

    # Update package lists
    log_info "Updating package lists..."
    sudo apt update

    # Read all packages from packages.list file
    local file_packages
    file_packages=($(read_packages_file))

    if [[ ${#file_packages[@]} -eq 0 ]]; then
        log_error "No packages found in $PACKAGES_FILE"
        return 1
    fi

    local unique_packages=("${file_packages[@]}")

    # Filter out already installed packages
    local to_install
    to_install=($(filter_installed_packages "${unique_packages[@]}"))

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All packages are already installed"
        return 0
    fi

    # Install packages
    log_info "Installing ${#to_install[@]} packages..."
    if install_packages "${to_install[@]}"; then
        log_success "All packages installed successfully"
    else
        log_error "Some packages failed to install"
        return 1
    fi

    # Setup alternatives for fd-find (if installed)
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        log_info "Setting up fd alternative for fdfind..."
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
        log_success "fd alternative created"
    fi

    # Setup alternatives for batcat (if installed)
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        log_info "Setting up bat alternative for batcat..."
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
        log_success "bat alternative created"
    fi

    log_success "Apt package installation completed"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --core-only    Install only core packages"
        echo "  --list         List all packages that would be installed"
        exit 0
        ;;
    --core-only)
        log_info "Installing first 15 packages only (legacy core packages)..."
        sudo apt update
        local file_packages
        file_packages=($(read_packages_file))
        local core_packages=("${file_packages[@]:0:15}")
        local to_install
        to_install=($(filter_installed_packages "${core_packages[@]}"))
        if [[ ${#to_install[@]} -gt 0 ]]; then
            install_packages "${to_install[@]}"
        else
            log_success "All core packages are already installed"
        fi
        ;;
    --list)
        if [[ -f "$PACKAGES_FILE" ]]; then
            echo "All packages from $PACKAGES_FILE:"
            while IFS= read -r line; do
                if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
                    echo "  $line"
                fi
            done < "$PACKAGES_FILE"
        else
            log_error "Packages file not found: $PACKAGES_FILE"
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
