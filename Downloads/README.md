# .dotfiles

## Using `git --bare`-repository
To avoid nesting repositories, symlinking, and to introduce a simpler way of adding things to the .dotfiles repostitory, I've used a bare repository to backup my dotfiles and other config files.

Alias: `alias config '/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME'`
(alias config="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME" for zsh, bash etc)


Run: `config config --local status.showUntrackedFiles no` avoid untracked files to be shown.

### Usage 
`config add filename`

`config commit -m "msg"`

`config status`

etc. Same as git.

Auto-add: `configadd`-alias will add changes from `nvim`, `kitty`, `fish` and `.tmux.conf` (alias in config.fish)


Source [guide](https://www.atlassian.com/git/tutorials/dotfiles).
