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

## Recommended Flows

For a local machine where your package manager is already set up:

```sh
./bin/bootstrap --install
```

For a fresh Linux server:

```sh
./bin/bootstrap
sudo ./bin/install-packages
```

This split is intentional:

- `./bin/bootstrap` is user-level setup. It seeds local overrides and symlinks the managed config files into your home directory.
- `sudo ./bin/install-packages` handles system package installation separately, so the bootstrap step does not accidentally write into `/root`.

Avoid running `sudo ./bin/bootstrap --install` unless you specifically want to bootstrap the root user.

## What The Scripts Do

`./bin/bootstrap`

- seeds `local/zsh.local` and `local/gitconfig.local` from their example files when they are missing
- symlinks the managed config files into `~`
- prints a follow-up command for setting your default shell to `zsh`

`./bin/bootstrap --install`

- runs the normal bootstrap flow first
- then calls `./bin/install-packages`
- keeps bootstrap successful even if package installation reports actionable problems

`./bin/install-packages`

- uses Homebrew on macOS
- prefers `apt-get` on Linux, with Homebrew as a fallback only when `apt-get` is unavailable
- prints readable progress logs and a follow-up checklist for anything it does not run automatically

Typical follow-ups include:

- `sudo ./bin/install-packages`
- `sudo add-apt-repository -y universe && sudo apt update`
- `curl -sS https://starship.rs/install.sh | sh`
- `chsh -s "$(command -v zsh)"`

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
