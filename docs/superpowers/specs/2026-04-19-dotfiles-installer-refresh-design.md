# Dotfiles Installer Refresh Design

## Summary

Update the existing dotfiles bootstrap and installer scripts to better support fresh Ubuntu servers while preserving macOS support. The refreshed design should make the scripts easier to follow in real time by adding structured, readable console output and by separating automatic actions from explicit user follow-up commands.

This is a behavior and UX refinement of the existing dotfiles repo, not a new provisioning system.

## Goals

- Make `bin/install-packages` work well on Ubuntu and other `apt`-based Linux systems without regressing macOS behavior.
- Keep `bin/bootstrap` focused on user-level config linking and local-file seeding.
- Add clear, attractive progress logging so a human can understand what the scripts are doing as they run.
- Print a final follow-up checklist for actions the script should not run automatically.
- Keep the scripts understandable and debuggable, with small helper functions instead of ad hoc branching.

## Non-Goals

- Full Linux distro abstraction across every package manager
- Automatic shell switching via `chsh`
- Automatic repository enabling such as forcing `universe`
- Automatic installation of tools from arbitrary curl pipes unless explicitly invoked by the user later
- Turning `bootstrap` into a general-purpose machine provisioning tool

## Scope

This design updates:

- `bin/install-packages`
- `bin/bootstrap`
- `README.md`

It does not require changes to the core managed dotfiles unless needed for documentation consistency.

## Design Principles

- Automatic actions should stay safe and unsurprising.
- User-affecting or privilege-sensitive actions should be printed as follow-up commands instead of being run automatically.
- Logs should be visually structured and easy to scan.
- Ubuntu should be first-class on Linux, while generic Linux fallback messaging remains intact.
- macOS support must remain straightforward through Homebrew.

## Updated Script Responsibilities

### `bin/bootstrap`

`bin/bootstrap` remains the user-level entrypoint.

Responsibilities:

- seed local override files if missing
- link managed config files into `~`
- print progress/log output for each step
- optionally delegate package installation when invoked with `--install`
- print a final follow-up checklist for user-run actions

Privilege behavior for `--install`:

- `bin/bootstrap --install` should always perform the user-level bootstrap work first
- it may invoke `bin/install-packages` directly after that
- it must not attempt to self-escalate with `sudo`
- if package installation requires root and the user is not root, it should print an explicit follow-up command such as `sudo ./bin/install-packages`

`bin/bootstrap` should not:

- run `chsh`
- assume it is being executed with `sudo`
- become responsible for Linux repo management details

### `bin/install-packages`

`bin/install-packages` becomes the package-install orchestration script.

Responsibilities:

- detect package manager and platform path
- print clear logs for each package attempt
- support Homebrew cleanly on macOS
- support Ubuntu well through `apt`
- record deferred/manual steps for final follow-up output
- distinguish clearly between install success, skipped packages, missing packages, and permission/setup issues

## Linux Strategy

Package-manager precedence on Linux:

- if `apt-get` is present, prefer the `apt` path even if Linux Homebrew is also installed
- Linux Homebrew should not override the Ubuntu-first behavior unless explicitly added later as a separate design choice

### Ubuntu-First Behavior

When `apt-get` is present:

- treat Ubuntu and similar `apt` systems as supported
- optionally run `apt update` when appropriate for package install flow
- attempt installation package-by-package so one failure does not abort the whole process
- treat known package-manager failures separately from package absence
- if package availability looks incomplete, print the exact `universe` enable command as a follow-up instead of enabling it automatically

The initial expected apt package set is:

Required:

- `zsh`
- `git`
- `fzf`
- `zoxide`
- `bat`
- `eza`

Best-effort follow-up:

- `starship`

`starship` should not be assumed to be available from apt. If it is not installable through the detected package manager path, it should be moved to the follow-up checklist rather than treated like a failed required package.

### Linux Fallback Behavior

If a non-Homebrew, non-apt system is detected:

- log that no supported package manager path was found
- skip package installation cleanly
- print follow-up guidance instead of failing with unclear output

## macOS Strategy

When Homebrew is present:

- install the supported package list through `brew`
- log package attempts and results clearly
- preserve the current simple macOS path

The expected Homebrew package set is:

Required:

- `zsh`
- `git`
- `fzf`
- `zoxide`
- `bat`
- `eza`
- `starship`

If Homebrew is missing:

- print an explicit follow-up item explaining that Homebrew is required for automatic package installation on macOS

## Logging Design

Both scripts should adopt structured logging helpers.

Expected log categories:

- `[info]` for current step / context
- `[done]` for successful actions
- `[warn]` for skipped or degraded behavior
- `[fail]` for actionable failures that prevent a step from completing

Console output should be:

- human-readable
- visually consistent
- concise but descriptive

The logs should explain:

- which script is running
- which platform/package-manager branch was chosen
- which file or package is being processed
- whether a step succeeded, was skipped, or requires manual intervention

The output should feel intentional and easy on the eyes, but stay ASCII-only and avoid decorative clutter that harms portability.

## Follow-Up Checklist

`bin/install-packages` should be the canonical owner of install-related follow-up output.

- when `bin/install-packages` runs directly, it prints its own final follow-up checklist
- when `bin/bootstrap --install` delegates to `bin/install-packages`, bootstrap should not duplicate the installer checklist
- `bin/bootstrap` may still print bootstrap-specific follow-ups if needed, but install-related follow-ups should come from `bin/install-packages`

At the end of install/bootstrap, print a final flat checklist for actions the script did not run automatically.

This includes at least:

- `If you want your user shell to default to zsh, run: chsh -s "$(command -v zsh)"`

Conditional follow-ups may include:

- enabling `universe` if apt packages are missing and that appears to be the likely reason
- a `starship` install command when `starship` was not installed automatically
- instructions to rerun `sudo ./bin/install-packages` if the user attempted package installation without sufficient privileges

The follow-up section should explain why each command is suggested, not just print raw commands.

## Permission Handling

The refreshed installer should distinguish:

- package unavailable
- package manager missing
- insufficient privileges
- setup prerequisite not met

In particular, a non-root `apt-get` permission error should not be mislabeled as “package unavailable.”

## Exit Status Contract

`bin/install-packages` should:

- exit `0` when all required automatic install work completed successfully
- exit non-zero when there are actionable install problems such as insufficient privileges, missing setup prerequisites, or package-manager failures that require user action
- still print follow-up guidance before exiting non-zero where possible

`bin/bootstrap --install` should:

- always complete the user-level bootstrap work first
- invoke `bin/install-packages` if requested
- continue to print follow-up guidance even if installation reports actionable problems
- exit `0` if the user-level bootstrap work succeeded, even when `bin/install-packages` reported actionable problems
- surface installer issues clearly in logs while relying on `bin/install-packages` to print install-related follow-up commands

## README Updates

The README should document the intended server flow more clearly:

```sh
./bin/bootstrap
sudo ./bin/install-packages
```

It should also document:

- `./bin/bootstrap --install` as a convenience path
- that `./bin/bootstrap --install` does not self-escalate and may print `sudo ./bin/install-packages` when root is required
- that the scripts may print follow-up commands instead of running every action automatically
- that shell-default changes are suggested, not enforced

## Proposed Internal Structure

The implementation should favor small shell helpers such as:

- logging helpers
- package-manager-specific install functions
- follow-up collection/printing helpers

Avoid large monolithic branching blocks where possible.

## Validation Requirements

The implementation should be validated with checks for:

- readable progress output during bootstrap
- readable progress output during package installation
- non-root apt permission errors produce correct messaging
- `bootstrap --install` on Linux preserves user-level bootstrap work and then prints the correct `sudo ./bin/install-packages` follow-up when root is required
- likely-missing Ubuntu repo coverage produces a `universe` follow-up command instead of automatic repo modification
- apt package failures do not abort the entire install flow
- macOS/Homebrew path still works as expected
- follow-up checklist prints the expected `chsh` guidance

## Risks And Mitigations

### Risk: Logging becomes noisy or hard to scan

Mitigation:
Use a small fixed set of log levels and keep messages concise.

### Risk: Linux behavior becomes Ubuntu-only in practice

Mitigation:
Keep generic fallback messaging for unsupported package managers and avoid pretending universal Linux support exists.

### Risk: The installer grows into a provisioning framework

Mitigation:
Keep clear boundaries between bootstrap, package install, and printed follow-up actions.

## Implementation Notes For Planning

The implementation plan should cover:

- refactoring `bin/install-packages` into structured helpers
- adding readable logging to both scripts
- improving apt-specific error handling and package behavior
- printing a final follow-up checklist
- updating README instructions to match the refined flow

The plan should treat this as a focused behavior/documentation update to an existing repo, not a net-new bootstrap system.
