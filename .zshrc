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

# Apply custom keybindings after zsh-vi-mode initializes keymaps.
# Sage and completion keys use Ctrl chords for portability (Mac, Linux, WSL).
# Tab always runs zsh completion; sage accept uses dedicated Ctrl bindings.
function zvm_after_init() {
  # zsh-sage (vi insert mode)
  bindkey -M viins '^O' forward-char    # Ctrl+O — accept full suggestion
  bindkey -M viins '^T' forward-word    # Ctrl+T — accept one word of suggestion
  bindkey -M viins '^N' sage-cycle      # Ctrl+N — cycle alternative suggestions
  bindkey -M viins '^G' sage-dismiss    # Ctrl+G — dismiss ghost text

  # Fuzzy completion picker (completion.zsh)
  bindkey -M viins '^F' pick-completion # Ctrl+F — fuzzy history/files/commands

  # Standard zsh completion (sage re-suggests via its expand-or-complete wrapper)
  bindkey -M viins '^I' expand-or-complete
  bindkey -M viins '^[[Z' reverse-menu-complete
  bindkey -M viins '^[[1;2Z' reverse-menu-complete
}
# Load zsh-vi-mode plugin after zsh-sage so we can rebind keys in zvm_after_init.
[[ -r "$DOTCONFIG/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]] && source "$DOTCONFIG/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# Define SDKMAN installation directory.
export SDKMAN_DIR="$HOME/.sdkman"
# Source SDKMAN bootstrap script when present.
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
