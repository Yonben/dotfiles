git_main_branch() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    printf '%s\n' "git_main_branch: not a git repository" >&2
    return 1
  fi

  if git show-ref --verify --quiet refs/heads/main; then
    printf '%s\n' "main"
    return 0
  fi

  if git show-ref --verify --quiet refs/heads/master; then
    printf '%s\n' "master"
    return 0
  fi

  remote_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [ -n "$remote_head" ]; then
    printf '%s\n' "${remote_head#origin/}"
    return 0
  fi

  printf '%s\n' "git_main_branch: could not determine the main branch" >&2
  return 1
}

gcm() {
  branch="$(git_main_branch)" || return 1
  git checkout "$branch"
}
