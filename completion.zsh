# Requires
# brew install fzy, tac, xe, coreutils, ffind, ag

# Load more completions
fpath=($DOTCONFIG/zsh/zsh-completions/src $fpath)

# Should be called before compinit
zmodload zsh/complist

autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

# Zstyle pattern
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true

zle -C alias-expension complete-word _generic
bindkey '^Xa' alias-expension
zstyle ':completion:alias-expension:*' completer _expand_alias

# Use cache for commands which use it

# Allow you to select in a menu
zstyle ':completion:*' menu select

# Autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true

zstyle ':completion:*' file-sort modification

zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'
# Colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# Only display some tags for the command cd
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
# zstyle ':completion:*:complete:git:argument-1:' tag-order !aliases

# Required for completion to be in good groups (named after the tags)
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# See ZSHCOMPWID "completion matching control"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' keep-prefix true

zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# Search and replay a command from the shell history.
# (Will output the command but not execute.)
function _fzy_history() {
    tac "${HISTFILE:-$ZDOTDIR/.zhistory}" | fzy -p 'History > ' \
        | awk '{ print substr($0, index($0, ";") + 1) }'
}

# A completion fallback if something more specific isn't available.
function _fzy_generic_find() {
    ffind "$PWD" 2>/dev/null | fzy -p 'Files > ' \
        | xargs printf '%s %s\n' "$*"
    #ag --silent -l -g $PWD | fzy -p 'Files > ' \
    #    | xargs printf '%s %s\n' "$*"
}

function _fzy_git() {
    {
    	git branch --format='%(refname:short)' --sort=-committerdate;
    	git branch --format='%(refname:short)' --sort=-committerdate -r;
    } \
    | fzy -p 'Git refs > ' \
    | xe printf '%s %s' "$*"
}

function _fzy_cd() {
    md="$1"; shift 1
    find "${2:-.}" \( -name .git -o -name Library \) -prune -o -type d -print | fzy -p "Directories > " -q "$*" \
	| xe printf '%s %s\n' "$cmd"
}

function _fzy_vim() {
    md="$1"; shift 1
    find "${2:-.}" \( -name .git -o -name Library \) -prune -o -type f -print | fzy -p "Files > " -q "$*" \
	| xe printf '%s %s\n' "$cmd"
}

# Invoke a fuzzy-finder to complete history, file paths, or command arguments
# Press ctrl-f to start completion.
# (This idea is stolen from fzf.)
#
# Usage:
#   <[empty cli]> - complete from shell history.
#   <cmd> - complete from _fzy_<cmd> script or funciton output.
#   <cmd> - falls back to generic file path completion.
#
# New completions can be added for a <cmd> by adding a shell function or
# a shell script on PATH with the pattern _fzy_<cmd>. The script will be
# invoked with the command name and any arguments as ARGV and should print the
# full resulting command and any additions to stdout.
# from https://github.com/whiteinge/dotfiles/blob/eed357dc/.zshrc#L276-L335
pick-completion() {
    setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins

    local tokens=(${(z)LBUFFER})
    local cmd=${tokens[1]}
    local cmd_fzy_match

    if [[ ${#tokens} -lt 1 ]]; then
        cmd_fzy_match=( '_fzy_history' )
    else
        # Filter (:#) the arrays of the names ((k)) Zsh function and scripts on
        # PATH and remove ((M)) entries that don't match "_fzy_<cmdname>":
        cmd_fzy_match=${(M)${(k)functions}:#_fzy_${cmd}}
        if [[ ${#cmd_fzy_match} -eq 0 ]]; then
            cmd_fzy_match=${(M)${(k)commands}:#_fzy_${cmd}}
            if [[ ${#cmd_fzy_match} -eq 0 ]]; then
                cmd_fzy_match=( '_fzy_generic_find' )
            fi
        fi
    fi

    zle -M "Gathering suggestions..."
    zle -R

    local result=$($cmd_fzy_match "${tokens[@]}")
    if [ -n "$result" ]; then
        LBUFFER="$result"
    fi

    zle reset-prompt
}

zle -N pick-completion
bindkey '^F' pick-completion

proj() {
    cd $(find ~/projects -maxdepth 1 -type d | fzy)
}
