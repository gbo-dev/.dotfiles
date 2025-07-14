.PHONY: help install install-interactive install-minimal stow unstow clean test lint fmt check

# Default target
help:
	@echo "Dotfiles Setup Automation"
	@echo "========================="
	@echo ""
	@echo "Available targets:"
	@echo "  help               Show this help message"
	@echo "  install            Full installation (recommended)"
	@echo "  install-interactive Full installation with interactive prompts"
	@echo "  install-minimal    Minimal installation (essential tools only)"
	@echo "  stow               Apply dotfile configurations only"
	@echo "  unstow             Remove dotfile configurations"
	@echo "  clean              Clean up temporary files"
	@echo "  test               Run tests and validation"
	@echo "  lint               Run linting checks"
	@echo "  fmt                Format shell scripts"
	@echo "  check              Run all checks (test + lint)"
	@echo ""
	@echo "Examples:"
	@echo "  make install           # Full automatic installation"
	@echo "  make install-interactive # Choose what to install"
	@echo "  make install-minimal   # Essential tools only"
	@echo "  make stow              # Only apply configurations"

# Full installation (recommended)
install:
	@echo "Running full dotfiles installation..."
	./install.sh

# Interactive installation
install-interactive:
	@echo "Running interactive dotfiles installation..."
	./install.sh --interactive

# Minimal installation
install-minimal:
	@echo "Running minimal dotfiles installation..."
	./install.sh --minimal

# Apply dotfile configurations using stow
stow:
	@echo "Applying dotfile configurations..."
	@for config in nvim tmux zsh ghostty zed alacritty kitty; do \
		if [ -d "$$config" ]; then \
			echo "Stowing $$config..."; \
			if ! stow $$config 2>/dev/null; then \
				echo "Warning: Conflicts detected for $$config, attempting to adopt..."; \
				if stow $$config --adopt 2>/dev/null; then \
					echo "Success: $$config configuration adopted"; \
				else \
					echo "Warning: Failed to apply $$config configuration"; \
				fi; \
			else \
				echo "Success: $$config configuration applied"; \
			fi; \
		fi; \
	done
	@echo "Dotfiles configuration completed"

# Remove dotfile configurations
unstow:
	@echo "Removing dotfile configurations..."
	@for config in nvim tmux zsh ghostty zed alacritty kitty; do \
		if [ -d "$$config" ]; then \
			echo "Unstowing $$config..."; \
			stow -D $$config || echo "Warning: Failed to unstow $$config"; \
		fi; \
	done
	@echo "Dotfiles removed successfully"

# Legacy targets for compatibility
deps:
	@echo "Installing system dependencies only..."
	./install.sh --no-editors --no-development --no-terminals --no-dotfiles

editors:
	@echo "Installing editors only..."
	./install.sh --no-packages --no-development --no-terminals --no-dotfiles

development:
	@echo "Installing development tools only..."
	./install.sh --no-packages --no-editors --no-terminals --no-dotfiles

terminals:
	@echo "Installing terminal applications only..."
	./install.sh --no-packages --no-editors --no-development --no-dotfiles

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	@find . -name "*.tmp" -type f -delete 2>/dev/null || true
	@find . -name "*.log" -type f -delete 2>/dev/null || true
	@find . -name ".DS_Store" -type f -delete 2>/dev/null || true
	@echo "Cleanup completed"

# Run tests and validation
test:
	@echo "Running tests and validation..."
	@echo "Checking required commands..."
	@command -v stow >/dev/null 2>&1 || { echo "ERROR: stow is not installed"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "ERROR: git is not installed"; exit 1; }
	@echo "Validating dotfiles structure..."
	@for config in nvim tmux zsh; do \
		if [ ! -d "$$config" ]; then \
			echo "WARNING: $$config directory not found"; \
		fi; \
	done
	@echo "Checking script permissions..."
	@for script in setup.sh install/*.sh; do \
		if [ -f "$$script" ] && [ ! -x "$$script" ]; then \
			echo "WARNING: $$script is not executable"; \
		fi; \
	done
	@echo "Tests completed"

# Run linting checks
lint:
	@echo "Running linting checks..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck on shell scripts..."; \
		find . -name "*.sh" -type f -exec shellcheck {} + || echo "Shellcheck found issues"; \
	else \
		echo "Warning: shellcheck not found, skipping shell script linting"; \
	fi
	@echo "Linting completed"

# Format shell scripts
fmt:
	@echo "Formatting shell scripts..."
	@if command -v shfmt >/dev/null 2>&1; then \
		echo "Running shfmt on shell scripts..."; \
		find . -name "*.sh" -type f -exec shfmt -i 4 -w {} +; \
		echo "Shell scripts formatted"; \
	else \
		echo "Warning: shfmt not found, skipping shell script formatting"; \
	fi
	@echo "Setting correct permissions..."
	@chmod 755 install.sh
	@chmod 755 lib/*.sh
	@echo "Formatting completed"

# Run all checks
check: test lint

# Quick development setup (minimal)
dev-quick:
	@echo "Quick development setup..."
	./install/apt-packages.sh --core-only
	./install/editors.sh --neovim-only
	stow nvim zsh tmux

# Update all tools to latest versions
update:
	@echo "Updating system packages..."
	sudo apt update && sudo apt upgrade -y
	@if command -v nvim >/dev/null 2>&1; then \
		echo "Updating Neovim..."; \
		./install/editors.sh --neovim-only || echo "Failed to update Neovim"; \
	fi
	@if command -v rustup >/dev/null 2>&1; then \
		echo "Updating Rust..."; \
		rustup update || echo "Failed to update Rust"; \
	fi
	@if command -v npm >/dev/null 2>&1; then \
		echo "Updating npm packages..."; \
		sudo npm update -g || echo "Failed to update npm packages"; \
	fi
	@echo "Updates completed"

# Show system information
info:
	@echo "System Information"
	@echo "=================="
	@echo "OS: $$(lsb_release -d | cut -f2)"
	@echo "Kernel: $$(uname -r)"
	@echo "Architecture: $$(uname -m)"
	@echo ""
	@echo "Installed Tools"
	@echo "==============="
	@command -v nvim >/dev/null 2>&1 && echo "Neovim: $$(nvim --version | head -n1 | cut -d' ' -f2)" || echo "Neovim: not installed"
	@command -v zed >/dev/null 2>&1 && echo "Zed: installed" || echo "Zed: not installed"
	@command -v code >/dev/null 2>&1 && echo "VS Code: $$(code --version | head -n1)" || echo "VS Code: not installed"
	@command -v ghostty >/dev/null 2>&1 && echo "Ghostty: installed" || echo "Ghostty: not installed"
	@command -v tmux >/dev/null 2>&1 && echo "Tmux: $$(tmux -V)" || echo "Tmux: not installed"
	@command -v zsh >/dev/null 2>&1 && echo "Zsh: $$(zsh --version)" || echo "Zsh: not installed"
	@command -v git >/dev/null 2>&1 && echo "Git: $$(git --version | cut -d' ' -f3)" || echo "Git: not installed"
	@command -v docker >/dev/null 2>&1 && echo "Docker: $$(docker --version | cut -d' ' -f3 | tr -d ',')" || echo "Docker: not installed"
	@command -v go >/dev/null 2>&1 && echo "Go: $$(go version | cut -d' ' -f3)" || echo "Go: not installed"
	@command -v rustc >/dev/null 2>&1 && echo "Rust: $$(rustc --version | cut -d' ' -f2)" || echo "Rust: not installed"
	@command -v node >/dev/null 2>&1 && echo "Node.js: $$(node --version)" || echo "Node.js: not installed"

# Backup existing configurations before applying
backup:
	@echo "Creating backup of existing configurations..."
	@backup_dir="$$HOME/.dotfiles-backup-$$(date +%Y%m%d-%H%M%S)"; \
	mkdir -p "$$backup_dir"; \
	for config in .zshrc .tmux.conf .config/nvim .config/ghostty .config/zed; do \
		if [ -e "$$HOME/$$config" ]; then \
			echo "Backing up $$config..."; \
			cp -r "$$HOME/$$config" "$$backup_dir/" 2>/dev/null || true; \
		fi; \
	done; \
	echo "Backup created at: $$backup_dir"

# Restore configurations and stow with adoption
adopt: backup
	@echo "Adopting existing configurations..."
	@for config in nvim tmux zsh ghostty zed alacritty kitty; do \
		if [ -d "$$config" ]; then \
			echo "Adopting $$config configuration..."; \
			stow $$config --adopt || echo "Warning: Failed to adopt $$config"; \
		fi; \
	done
	@echo "Configurations adopted. Review changes with 'git diff'"
