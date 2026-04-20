#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

assert_contains() {
  haystack="$1"
  needle="$2"
  if printf '%s' "$haystack" | grep -F -- "$needle" >/dev/null 2>&1; then
    return 0
  fi

  printf '%s\n' "missing expected output: $needle" >&2
  return 1
}

assert_not_contains() {
  haystack="$1"
  needle="$2"
  if printf '%s' "$haystack" | grep -F -- "$needle" >/dev/null 2>&1; then
    printf '%s\n' "unexpected output present: $needle" >&2
    return 1
  fi

  return 0
}

cleanup_dir() {
  rm -rf "$1"
}

run_installs_missing_plugins_test() {
  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-plugin-test.XXXXXX")"
  tmp_log="$tmp_root/git.log"

  mkdir -p "$tmp_root/bin" "$tmp_root/dotfiles/zsh/plugins"
  cat > "$tmp_root/bin/git" <<EOF
#!/usr/bin/env sh
printf '%s\n' "\$*" >> "$tmp_log"
if [ "\$1" = "clone" ]; then
  for last_arg do :; done
  mkdir -p "\$last_arg"
  exit 0
fi
exit 1
EOF
  chmod +x "$tmp_root/bin/git"

  output="$(
    PATH="$tmp_root/bin:/usr/bin:/bin" \
      DOTFILES_DIR_OVERRIDE="$tmp_root/dotfiles" \
      "$ROOT_DIR/bin/install-zsh-plugins" 2>&1
  )"

  test -d "$tmp_root/dotfiles/zsh/plugins/zsh-autosuggestions"
  test -d "$tmp_root/dotfiles/zsh/plugins/fast-syntax-highlighting"
  assert_contains "$output" "[done] Installed zsh plugin: zsh-autosuggestions"
  assert_contains "$output" "[done] Installed zsh plugin: fast-syntax-highlighting"

  cleanup_dir "$tmp_root"
}

run_skips_existing_plugins_test() {
  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-plugin-test.XXXXXX")"

  mkdir -p \
    "$tmp_root/bin" \
    "$tmp_root/dotfiles/zsh/plugins/zsh-autosuggestions" \
    "$tmp_root/dotfiles/zsh/plugins/fast-syntax-highlighting"
  cat > "$tmp_root/bin/git" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "git should not be called" >&2
exit 1
EOF
  chmod +x "$tmp_root/bin/git"

  output="$(
    PATH="$tmp_root/bin:/usr/bin:/bin" \
      DOTFILES_DIR_OVERRIDE="$tmp_root/dotfiles" \
      "$ROOT_DIR/bin/install-zsh-plugins" 2>&1
  )"

  assert_contains "$output" "[info] Skipping existing zsh plugin: zsh-autosuggestions"
  assert_contains "$output" "[info] Skipping existing zsh plugin: fast-syntax-highlighting"

  cleanup_dir "$tmp_root"
}

run_follow_up_on_clone_failure_test() {
  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-plugin-test.XXXXXX")"

  mkdir -p "$tmp_root/bin" "$tmp_root/dotfiles/zsh/plugins"
  cat > "$tmp_root/bin/git" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "fatal: network unavailable" >&2
exit 1
EOF
  chmod +x "$tmp_root/bin/git"

  output="$(
    PATH="$tmp_root/bin:/usr/bin:/bin" \
      DOTFILES_DIR_OVERRIDE="$tmp_root/dotfiles" \
      "$ROOT_DIR/bin/install-zsh-plugins" 2>&1
  )"

  assert_contains "$output" "[warn] Failed to install zsh plugin: zsh-autosuggestions"
  assert_contains "$output" "Before you finish setup, review these follow-up steps:"
  assert_contains "$output" "git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions"
  assert_contains "$output" "git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting"

  cleanup_dir "$tmp_root"
}

run() {
  run_installs_missing_plugins_test
  run_skips_existing_plugins_test
  run_follow_up_on_clone_failure_test
}

run "$@"
