export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [ -f "$DOTFILES_DIR/local/zsh.local" ]; then
  . "$DOTFILES_DIR/local/zsh.local"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat -pp"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --color=always --long --git --icons=always"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
