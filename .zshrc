# Initialize Homebrew environment variables when Homebrew is installed.
if command -v brew >/dev/null 2>&1; then
  # Evaluate shellenv output to set PATH, MANPATH, and HOMEBREW_* vars.
  eval "$(brew shellenv)"
fi

# Compatibility: some widget wrappers run with `no_unset`, while zsh-vi-mode
# redraw hooks reference $TMUX directly.
# Ensure TMUX is always defined (empty outside tmux).
typeset -g TMUX="${TMUX-}"

# Set secure default file permissions for newly created files/directories.
umask 027

# Add pure prompt functions to fpath only when plugin files exist.
if [[ -r "$DOTCONFIG/zsh/pure/pure.zsh" ]]; then
  fpath+=($DOTCONFIG/zsh/pure)
  # Load zsh prompt initialization helpers.
  autoload -U promptinit; promptinit
  # Activate the pure prompt theme.
  prompt pure
fi

# Load completion configuration (styles, completion widgets, helper funcs).
[[ -r "$DOTCONFIG/zsh/completion.zsh" ]] && source "$DOTCONFIG/zsh/completion.zsh"
# Load user aliases.
[[ -r "$DOTCONFIG/zsh/aliases" ]] && source "$DOTCONFIG/zsh/aliases"
# Load zsh-sage suggestion plugin.
[[ -r "$DOTCONFIG/zsh/zsh-sage/zsh-sage.plugin.zsh" ]] && source "$DOTCONFIG/zsh/zsh-sage/zsh-sage.plugin.zsh"

# Initialize zsh-vi-mode at source time (not delayed to first prompt).
ZVM_INIT_MODE=sourcing
# Start each command line in insert mode.
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

# Tab behavior with zsh-sage:
# - Tab: accept full suggestion, else normal completion
# - Shift+Tab: accept next word, else reverse completion
# Define custom widget for Tab behavior.
function _user_sage_tab_accept_or_complete() {
  # If ghost suggestion exists, accept full suggestion.
  if [[ -n "$POSTDISPLAY" ]]; then
    zle forward-char
  else
    # Otherwise run normal completion.
    zle expand-or-complete
  fi
}

# Define custom widget for Shift+Tab behavior.
function _user_sage_shtab_accept_word_or_reverse_complete() {
  # If ghost suggestion exists, accept one word from suggestion.
  if [[ -n "$POSTDISPLAY" ]]; then
    zle forward-word
  # If no suggestion, try reverse completion menu navigation.
  elif (( ${+widgets[reverse-menu-complete]} )); then
    zle reverse-menu-complete
  else
    # Fallback to standard completion when reverse menu widget is unavailable.
    zle expand-or-complete
  fi
}

# Apply custom keybindings after zsh-vi-mode initializes keymaps.
function zvm_after_init() {
  # Register custom Tab widget with ZLE.
  zle -N _user_sage_tab_accept_or_complete
  # Register custom Shift+Tab widget with ZLE.
  zle -N _user_sage_shtab_accept_word_or_reverse_complete

  # Keep zsh-sage cycling in insert mode.
  # Ctrl+N cycles zsh-sage candidates.
  bindkey -M viins '^N' sage-cycle
  # Ctrl+F opens fuzzy completion picker.
  bindkey -M viins '^F' pick-completion

  # Tab / Shift+Tab accept behavior for zsh-sage.
  # Tab key.
  bindkey -M viins '^I' _user_sage_tab_accept_or_complete
  # Common Shift+Tab sequence.
  bindkey -M viins '^[[Z' _user_sage_shtab_accept_word_or_reverse_complete
  # Alternate Shift+Tab sequence used by some terminals.
  bindkey -M viins '^[[1;2Z' _user_sage_shtab_accept_word_or_reverse_complete
}
# Load zsh-vi-mode plugin after zsh-sage so we can rebind keys in zvm_after_init.
[[ -r "$DOTCONFIG/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]] && source "$DOTCONFIG/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# Define SDKMAN installation directory.
export SDKMAN_DIR="$HOME/.sdkman"
# Source SDKMAN bootstrap script when present.
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
