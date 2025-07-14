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
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
INSTALL_MODE="full"
TARGET_HOST="localhost"
DRY_RUN=false
VERBOSE=false
ANSIBLE_TAGS=""
SKIP_TAGS=""

# Display help
show_help() {
    cat << EOF
Ansible Dotfiles Installation Script
===================================

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -m, --mode MODE         Installation mode: minimal, standard, full, development (default: full)
    -t, --target HOST       Target host (default: localhost)
    -d, --dry-run          Run in dry-run mode (check only)
    -v, --verbose          Verbose output
    --tags TAGS            Run only tasks with these tags (comma-separated)
    --skip-tags TAGS       Skip tasks with these tags (comma-separated)
    --check-deps           Check dependencies and exit
    --list-hosts           List available hosts and exit
    --list-tags            List available tags and exit

INSTALLATION MODES:
    minimal      - Core packages and basic dotfiles only
    standard     - Core packages, CLI tools, and dotfiles
    full         - Everything including editors, terminals, and dev tools
    development  - Standard + all development tools (Docker, Rust, Go, Node.js)

EXAMPLES:
    $0                                    # Full installation on localhost
    $0 --mode minimal                     # Minimal installation
    $0 --mode development --verbose       # Development setup with verbose output
    $0 --dry-run                         # Test run without making changes
    $0 --tags "packages,editors"         # Install only packages and editors
    $0 --skip-tags "development"         # Skip development tools

TAGS:
    always          - Always run (prerequisites)
    packages        - System package installation
    editors         - Editor installation (Neovim, Zed, VS Code)
    terminals       - Terminal applications (Ghostty, fonts)
    development     - Development tools (Docker, Rust, Go, Node.js)
    dotfiles        - Dotfiles configuration with stow
    stow            - Stow operations only
    config          - Configuration tasks only

EOF
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check system requirements
check_dependencies() {
    log_info "Checking system dependencies..."

    local missing_deps=()

    # Check for essential commands
    local required_commands=("python3" "pip" "git" "curl" "sudo")

    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and try again."
        return 1
    fi

    log_success "All system dependencies are available"
    return 0
}

# Install Ansible if not present
install_ansible() {
    if command_exists ansible-playbook; then
        local ansible_version
        ansible_version=$(ansible --version | head -n1 | cut -d' ' -f3)
        log_success "Ansible is already installed (version: $ansible_version)"
        return 0
    fi

    log_info "Ansible not found. Installing Ansible..."

    # Try different installation methods
    if command_exists apt; then
        # Debian/Ubuntu
        log_info "Installing Ansible via apt..."
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install -y ansible
    elif command_exists dnf; then
        # Fedora
        log_info "Installing Ansible via dnf..."
        sudo dnf install -y ansible
    elif command_exists yum; then
        # CentOS/RHEL
        log_info "Installing Ansible via yum..."
        sudo yum install -y epel-release
        sudo yum install -y ansible
    elif command_exists pacman; then
        # Arch Linux
        log_info "Installing Ansible via pacman..."
        sudo pacman -S --noconfirm ansible
    elif command_exists pip3; then
        # Fallback to pip
        log_info "Installing Ansible via pip3..."
        pip3 install --user ansible

        # Add to PATH if not already there
        local pip_bin_dir="$HOME/.local/bin"
        if [[ ":$PATH:" != *":$pip_bin_dir:"* ]]; then
            export PATH="$pip_bin_dir:$PATH"
            echo "export PATH=\"$pip_bin_dir:\$PATH\"" >> ~/.bashrc
        fi
    else
        log_error "Could not install Ansible. Please install it manually."
        return 1
    fi

    if command_exists ansible-playbook; then
        log_success "Ansible installed successfully"
    else
        log_error "Ansible installation failed"
        return 1
    fi
}

# Validate configuration
validate_config() {
    log_info "Validating Ansible configuration..."

    # Check if we're in the right directory
    if [[ ! -f "$SCRIPT_DIR/ansible.cfg" ]]; then
        log_error "ansible.cfg not found. Are you running this from the correct directory?"
        return 1
    fi

    # Check if inventory exists
    if [[ ! -f "$SCRIPT_DIR/inventory/hosts.yml" ]]; then
        log_error "Inventory file not found at inventory/hosts.yml"
        return 1
    fi

    # Check if main playbook exists
    if [[ ! -f "$SCRIPT_DIR/playbooks/main.yml" ]]; then
        log_error "Main playbook not found at playbooks/main.yml"
        return 1
    fi

    log_success "Ansible configuration validated"
}

# List available hosts
list_hosts() {
    log_info "Available hosts:"
    cd "$SCRIPT_DIR"
    ansible-inventory --list -i inventory/hosts.yml | jq -r '.all.children | keys[]' 2>/dev/null || \
    ansible-inventory --list -i inventory/hosts.yml | grep -E '^\s+"' | sed 's/[",]//g' | sort | uniq
}

# List available tags
list_tags() {
    log_info "Available tags:"
    echo "  always       - Prerequisites and essential tasks"
    echo "  packages     - System package installation"
    echo "  editors      - Editor installation (Neovim, Zed, VS Code)"
    echo "  terminals    - Terminal applications and fonts"
    echo "  development  - Development tools (Docker, Rust, Go, Node.js)"
    echo "  dotfiles     - Dotfiles configuration with stow"
    echo "  stow         - Stow operations only"
    echo "  config       - Configuration tasks only"
}

# Build ansible-playbook command
build_ansible_command() {
    local cmd="ansible-playbook"

    # Add configuration file
    cmd="$cmd -i inventory/hosts.yml"

    # Add target host
    cmd="$cmd --limit $TARGET_HOST"

    # Add verbosity
    if [[ "$VERBOSE" == "true" ]]; then
        cmd="$cmd -v"
    fi

    # Add dry run
    if [[ "$DRY_RUN" == "true" ]]; then
        cmd="$cmd --check --diff"
    fi

    # Add tags
    if [[ -n "$ANSIBLE_TAGS" ]]; then
        cmd="$cmd --tags $ANSIBLE_TAGS"
    fi

    # Add skip tags
    if [[ -n "$SKIP_TAGS" ]]; then
        cmd="$cmd --skip-tags $SKIP_TAGS"
    fi

    # Add extra vars for installation mode
    cmd="$cmd --extra-vars install_mode=$INSTALL_MODE"

    # Add the playbook
    cmd="$cmd playbooks/main.yml"

    echo "$cmd"
}

# Run the installation
run_installation() {
    log_info "Starting dotfiles installation with Ansible..."
    log_info "Mode: $INSTALL_MODE"
    log_info "Target: $TARGET_HOST"
    log_info "Dry run: $DRY_RUN"

    cd "$SCRIPT_DIR"

    local ansible_cmd
    ansible_cmd=$(build_ansible_command)

    log_info "Running: $ansible_cmd"
    echo

    if $ansible_cmd; then
        echo
        log_success "Installation completed successfully!"

        if [[ "$DRY_RUN" == "false" ]]; then
            echo
            log_info "Post-installation notes:"
            echo "1. Restart your terminal or run: exec zsh"
            echo "2. Open tmux and press prefix + I to install tmux plugins"
            echo "3. Open neovim to trigger plugin installation"
            echo "4. Run 'source ~/.zshrc' to load new environment"
        fi
    else
        echo
        log_error "Installation failed. Check the output above for details."
        return 1
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -m|--mode)
                INSTALL_MODE="$2"
                shift 2
                ;;
            -t|--target)
                TARGET_HOST="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --tags)
                ANSIBLE_TAGS="$2"
                shift 2
                ;;
            --skip-tags)
                SKIP_TAGS="$2"
                shift 2
                ;;
            --check-deps)
                check_dependencies
                exit $?
                ;;
            --list-hosts)
                list_hosts
                exit 0
                ;;
            --list-tags)
                list_tags
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Validate install mode
    case "$INSTALL_MODE" in
        minimal|standard|full|development)
            ;;
        *)
            log_error "Invalid install mode: $INSTALL_MODE"
            log_info "Valid modes: minimal, standard, full, development"
            exit 1
            ;;
    esac
}

# Main function
main() {
    echo -e "${BLUE}Ansible Dotfiles Installer${NC}"
    echo "=========================="
    echo

    parse_args "$@"

    # Run pre-flight checks
    check_dependencies || exit 1
    install_ansible || exit 1
    validate_config || exit 1

    # Run the installation
    run_installation
}

# Run main function with all arguments
main "$@"
