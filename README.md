# .dotfiles

Maintained using stow-created symlinks.

## Usage
Clone repo to `$HOME` and use `stow .` (GNU stow) inside repository directory.

`.git` will be ignored, and `stow` solves the symlinks.  

## Important
Ensure correct permissions to the dotfiles folder once cloned:
```
chmod 700 .dotfiles
chmod 600 .dotfiles/utilities/shell-scripts/*.sh
```
