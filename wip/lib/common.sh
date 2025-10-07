#!/usr/bin/env bash

# Common utilities and functions for dotfiles installation
# This file provides shared functionality across all installation scripts

set -euo pipefail

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1" >&2
    fi
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Detect system platform
get_platform() {
    case "$(uname -s)" in
        Linux)
            echo "linux"
            ;;
        Darwin)
            echo "macos"
            ;;
        *)
            log_error "Unsupported platform: $(uname -s)"
            return 1
            ;;
    esac
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
        armv7l)
            echo "armv7"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
}

# Check if running on supported system
check_system() {
    local platform
    platform=$(get_platform)

    if [[ "$platform" == "linux" ]]; then
        if ! command -v apt &> /dev/null; then
            log_error "This script requires apt package manager (Debian/Ubuntu)"
            log_info "Other Linux distributions are not currently supported"
            exit 1
        fi
        log_debug "Detected Linux with apt package manager"
    elif [[ "$platform" == "macos" ]]; then
        log_warning "macOS support is experimental"
        if ! command -v brew &> /dev/null; then
            log_error "Homebrew is required for macOS installation"
            log_info "Install Homebrew first: https://brew.sh"
            exit 1
        fi
        log_debug "Detected macOS with Homebrew"
    fi
}

# Get system info summary
get_system_info() {
    local platform arch
    platform=$(get_platform)
    arch=$(get_architecture)

    echo "Platform: $platform"
    echo "Architecture: $arch"

    if [[ "$platform" == "linux" ]]; then
        if command -v lsb_release &> /dev/null; then
            echo "Distribution: $(lsb_release -d | cut -f2)"
        elif [[ -f /etc/os-release ]]; then
            echo "Distribution: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
        fi
        echo "Kernel: $(uname -r)"
    elif [[ "$platform" == "macos" ]]; then
        echo "Version: $(sw_vers -productVersion)"
    fi
}

# Check if package is installed (Linux)
is_package_installed() {
    if [[ "$(get_platform)" == "linux" ]]; then
        dpkg -l "$1" &> /dev/null
    else
        # For macOS, check if brew package is installed
        brew list "$1" &> /dev/null
    fi
}

# Install single package
install_package() {
    local package="$1"
    local platform
    platform=$(get_platform)

    log_info "Installing $package..."

    if [[ "$platform" == "linux" ]]; then
        if sudo apt install -y "$package"; then
            log_success "$package installed successfully"
            return 0
        else
            log_error "Failed to install $package"
            return 1
        fi
    elif [[ "$platform" == "macos" ]]; then
        if brew install "$package"; then
            log_success "$package installed successfully"
            return 0
        else
            log_error "Failed to install $package"
            return 1
        fi
    fi
}

# Update system packages
update_system() {
    local platform
    platform=$(get_platform)

    log_step "Updating system packages..."

    if [[ "$platform" == "linux" ]]; then
        sudo apt update && sudo apt upgrade -y
    elif [[ "$platform" == "macos" ]]; then
        brew update && brew upgrade
    fi

    log_success "System updated"
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_debug "Creating directory: $dir"
        mkdir -p "$dir"
    fi
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    local description="${3:-file}"

    log_info "Downloading $description..."
    log_debug "URL: $url"
    log_debug "Output: $output"

    ensure_directory "$(dirname "$output")"

    if command_exists curl; then
        curl -fsSL -o "$output" "$url"
    elif command_exists wget; then
        wget -q -O "$output" "$url"
    else
        log_error "Neither curl nor wget is available"
        return 1
    fi

    log_success "$description downloaded"
}

# Extract archive
extract_archive() {
    local archive="$1"
    local destination="$2"
    local description="${3:-archive}"

    log_info "Extracting $description..."

    ensure_directory "$destination"

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$destination"
            ;;
        *.tar.bz2)
            tar -xjf "$archive" -C "$destination"
            ;;
        *.tar.xz)
            tar -xJf "$archive" -C "$destination"
            ;;
        *.zip)
            unzip -q "$archive" -d "$destination"
            ;;
        *)
            log_error "Unsupported archive format: $archive"
            return 1
            ;;
    esac

    log_success "$description extracted"
}

# Make file executable
make_executable() {
    local file="$1"
    chmod +x "$file"
    log_debug "Made executable: $file"
}

# Add path to shell configuration
add_to_path() {
    local path_to_add="$1"
    local description="$2"
    local shell_config="${3:-$HOME/.zshrc}"

    # Check if path is already in current PATH
    if echo "$PATH" | grep -q "$path_to_add"; then
        log_success "$description is already in PATH"
        return 0
    fi

    log_info "Adding $description to PATH..."

    if [[ -f "$shell_config" ]]; then
        # Check if path is already in shell config
        if ! grep -q "$path_to_add" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# $description" >> "$shell_config"
            echo "export PATH=\"$path_to_add:\$PATH\"" >> "$shell_config"
            log_success "Added $description to PATH in $shell_config"
        else
            log_success "$description path already configured"
        fi
    else
        log_warning "$shell_config not found. Add $path_to_add to your PATH manually"
    fi
}

# Check if we're in interactive mode
is_interactive() {
    [[ "${INTERACTIVE_MODE:-}" == "true" ]]
}

# Ask user confirmation (only in interactive mode)
ask_confirmation() {
    local prompt="$1"
    local default="${2:-N}"

    if ! is_interactive; then
        # Non-interactive mode: use default behavior
        if [[ "$default" == "Y" || "$default" == "y" ]]; then
            return 0
        else
            return 1
        fi
    fi

    local reply
    read -p "$prompt [$default]: " -r reply
    reply=${reply:-$default}

    if [[ "$reply" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Print section header
print_section() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title}) / 2 ))

    echo
    echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}$(printf '%*s' $padding)$title$(printf '%*s' $padding)${NC}"
    echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo
}

# Print installation summary
print_summary() {
    local items=("$@")

    echo
    log_success "Installation Summary:"
    for item in "${items[@]}"; do
        echo "  ✓ $item"
    done
    echo
}

# Cleanup temporary files
cleanup_temp() {
    local temp_dir="${1:-/tmp/dotfiles-install}"
    if [[ -d "$temp_dir" ]]; then
        log_debug "Cleaning up temporary directory: $temp_dir"
        rm -rf "$temp_dir"
    fi
}

# Set up signal handlers for cleanup
setup_cleanup() {
    local temp_dir="${1:-/tmp/dotfiles-install}"
    trap "cleanup_temp '$temp_dir'" EXIT INT TERM
}

# Get latest GitHub release version
get_latest_github_release() {
    local repo="$1"
    local api_url="https://api.github.com/repos/$repo/releases/latest"

    if command_exists curl; then
        curl -s "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    elif command_exists wget; then
        wget -qO- "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    else
        log_error "Neither curl nor wget is available"
        return 1
    fi
}

# Source this file safely
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_error "This file should be sourced, not executed directly"
    exit 1
fi

log_debug "Common utilities loaded"
