# Dotfiles

From this repository, use GNU Stow to symlink the configs into `~/.config`:

```sh
stow --target="$HOME" ghostty nvim
```

Run `stow --delete --target="$HOME" ghostty nvim` to remove the symlinks.
