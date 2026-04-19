# dotfiles

Portable terminal-first dotfiles for macOS and Linux.

## Supported Platforms

- macOS
- Linux

## Quick Start

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./bin/bootstrap
```

To also attempt package installation when a supported package manager is available:

```sh
./bin/bootstrap --install
```

## Managed Files

- `~/.zshrc`
- `~/.gitconfig`
- `~/.config/starship.toml`

## Local Overrides

Bootstrap seeds these files automatically if they are missing. Edit them locally as needed:

- `local/zsh.local.example` -> `local/zsh.local`
- `local/gitconfig.local.example` -> `local/gitconfig.local`

These local files are ignored by git.

## Backups

If a managed target already exists, bootstrap moves it aside to a timestamped backup before linking the repo-managed file.
