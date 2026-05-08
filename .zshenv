# XSG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"
export DOTCONFIG="$XDG_CONFIG_HOME"

# Append to PATH only when directory exists and is not already present.
path_append_if_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="${PATH:+$PATH:}$dir" ;;
  esac
}

# zsh
if [[ -x /opt/homebrew/bin/zsh ]]; then
  export SHELL=/opt/homebrew/bin/zsh
elif command -v zsh >/dev/null 2>&1; then
  export SHELL="$(command -v zsh)"
fi
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

# editor
export MYVIMDIR="$XDG_CONFIG_HOME/vim"
export MYVIMRC="$MYVIMDIR/vimrc"
export EDITOR=vim
export VISUAL=$EDITOR

# android
export ANDROID_HOME="$HOME/.android/sdk"
path_append_if_dir "$ANDROID_HOME/build-tools"
path_append_if_dir "$ANDROID_HOME/platform-tools"
path_append_if_dir "$ANDROID_HOME/emulator"

# colima & testcontainers
export COLIMA_HOME="$DOTCONFIG/colima"
if [[ -S "${COLIMA_HOME}/default/docker.sock" ]]; then
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  export TESTCONTAINERS_HOST_OVERRIDE="0.0.0.0"
  export DOCKER_HOST="unix://${COLIMA_HOME}/default/docker.sock"
fi
