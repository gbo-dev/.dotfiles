# Repository guidance

## Structure

This is a personal dotfiles repository. Most top-level application directories
are GNU Stow packages that mirror paths under `$HOME`; preserve that layout when
adding or moving configuration. `assets/`, `utils/`, and `packages.list/` are
shared resources, not necessarily Stow packages.

## Documentation

Keep `README.md` short and durable: it should cover repository purpose, layout,
and the basic Stow workflow. Do not add catalogs of applications, utilities,
keybindings, implementation details, or other information that must be updated
whenever a configuration changes. Prefer concise comments beside the relevant
configuration or script when local context is needed.

## Changes

- Preserve unrelated user changes in this often-dirty working tree.
- Keep scripts executable and validate shell syntax after editing them.
- Validate the affected application's configuration when a validator is
  available.
- Do not commit generated state, caches, or machine-specific runtime files.
