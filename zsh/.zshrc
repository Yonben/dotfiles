export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [ -f "$DOTFILES_DIR/local/zsh.local" ]; then
  . "$DOTFILES_DIR/local/zsh.local"
fi

if [ -f "$DOTFILES_DIR/zsh/aliases.zsh" ]; then
  . "$DOTFILES_DIR/zsh/aliases.zsh"
fi

if [ -f "$DOTFILES_DIR/zsh/git-functions.zsh" ]; then
  . "$DOTFILES_DIR/zsh/git-functions.zsh"
fi

if [ -f "$DOTFILES_DIR/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  . "$DOTFILES_DIR/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$DOTFILES_DIR/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
  . "$DOTFILES_DIR/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat -pp"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
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
