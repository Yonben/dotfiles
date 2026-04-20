# Dotfiles Zsh Plugins Design

## Goal

Extend the dotfiles repo so a fresh machine can install and load a small curated set of `zsh` plugins without depending on `oh-my-zsh`, while preserving the current fast bootstrap flow for laptops and servers.

## Scope

This change adds:

- automatic installation of `zsh-autosuggestions`
- automatic installation of `fast-syntax-highlighting`
- direct plugin loading from `zsh/plugins/`
- a repo-owned git alias/function layer for the small command set the user actually uses

This change does not add:

- `oh-my-zsh`
- a general-purpose `zsh` plugin manager
- automatic plugin updates on every bootstrap/install run
- a large alias surface copied from the upstream `oh-my-zsh` git plugin

## Design

### Plugin Storage

Plugin code lives under the repo at:

- `zsh/plugins/zsh-autosuggestions/`
- `zsh/plugins/fast-syntax-highlighting/`

These directories are managed by repo scripts rather than committed plugin source. This keeps the repo lightweight while still giving the shell a predictable load path.

### Installation Flow

`bin/install-packages` gains a plugin installation phase after package installation.

Behavior:

- if `git` is available, clone each plugin into its target directory when missing
- if a plugin directory already exists, skip it rather than updating in place
- if cloning fails because of network or git issues, log a warning and add a manual follow-up command
- plugin installation should not break the rest of the bootstrap flow if package installation has otherwise succeeded

The script should print readable progress logs consistent with the current installer style.

### Zsh Loading

`zsh/.zshrc` loads repo-owned support files and plugins defensively.

Load order:

1. local overrides
2. repo-owned git aliases/functions
3. optional plugin files if present
4. existing tool-native init hooks like `fzf`, `zoxide`, and `starship`

Each plugin source must be guarded with `[ -f ... ]` so shell startup stays clean when a plugin is missing.

### Git Alias Layer

The repo replaces the prior `oh-my-zsh` git plugin dependency with a minimal owned layer.

Simple aliases:

- `g='git'`
- `gp='git push'`
- `gl='git pull'`
- `gco='git checkout'`
- `gcb='git checkout -b'`

Functions:

- `git_main_branch()`
- `gcm()`

`git_main_branch()` should:

- prefer local `main` when present
- otherwise prefer local `master` when present
- otherwise detect the remote default branch when available
- otherwise fail with a readable error

`gcm()` should check out the branch returned by `git_main_branch()`.

## Error Handling

- missing plugin directories must not break shell startup
- plugin clone failures must be warnings with explicit follow-up commands
- existing plugin directories should be treated as already installed
- if `git` is unavailable during plugin installation, the script should log the skip and print the exact clone commands as follow-up steps

## Documentation

`README.md` should document:

- which plugins are installed automatically
- where they live in the repo
- that existing plugin directories are skipped, not updated
- that the git command shortcuts now come from repo-owned aliases/functions instead of `oh-my-zsh`

## Verification

At minimum, verify:

- `sh -n bin/install-packages`
- `zsh -n zsh/.zshrc`
- installer self-tests still pass
- a plugin-install harness can create plugin directories under `zsh/plugins/`
- shell startup remains clean if plugin directories are absent
