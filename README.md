# zsh config

Portable zsh setup for macOS, Linux, and WSL.

This repo tracks personal config files and uses git submodules for third-party plugins:

- `pure`
- `zsh-completions`
- `zsh-sage`
- `zsh-vi-mode`

## Clone

```bash
git clone --recurse-submodules <your-repo-url> ~/.config/zsh
cd ~/.config/zsh
```

If already cloned without submodules:

```bash
git submodule update --init --recursive
```

## Install on a target machine

Run:

```bash
./install.sh
```

What it does:

1. Ensures `~/.config/zsh` points to this repo (symlinked if cloned elsewhere).
2. Initializes/updates submodules.
3. Backs up existing `~/.zshenv` (if present) with a timestamp suffix.
4. Installs repo `.zshenv` to `~/.zshenv`.

Then start a new login shell.

## Updating

```bash
git pull --recurse-submodules
git submodule update --init --recursive
```

## Keymaps

Bindings below apply in **vi insert mode** (`viins`), unless noted. They use **Ctrl** chords so behavior is the same on macOS, Linux, and WSL.

### Tab completion

Configured in `completion.zsh` and rebound in `.zshrc` (`zvm_after_init`).

| Key | Action |
|---|---|
| **Tab** | Expand or complete (`expand-or-complete`) — command flags, paths, menu select |
| **Shift+Tab** | Reverse completion menu (`reverse-menu-complete`) |
| **Ctrl+X A** | Expand alias before completing (`alias-expension` in `completion.zsh`) |

Completion styles (groups, cache, fuzzy match) live in `completion.zsh`. Extra completion definitions come from the `zsh-completions` submodule.

### zsh-sage (ghost suggestions)

History-based inline suggestions from `zsh-sage`. Typing shows ghost text; accept it with Ctrl keys so **Tab stays free for real completion** (e.g. `gradle -` + Tab lists Gradle options, not a remembered command).

| Key | Action |
|---|---|
| **Ctrl+O** | Accept full suggestion (`forward-char`, sage-wrapped) |
| **Ctrl+T** | Accept one word of the suggestion (`forward-word`, sage-wrapped) |
| **Ctrl+N** | Cycle through alternative suggestions (`sage-cycle`) |
| **Ctrl+G** | Dismiss ghost text without inserting (`sage-dismiss`) |

Ghost text is also cleared on **Enter** and **Backspace**. Sage wraps Tab completion to refresh suggestions after a completion pass.

### Fuzzy picker

| Key | Action |
|---|---|
| **Ctrl+F** | Fuzzy picker (`pick-completion` in `completion.zsh`) — history when the line is empty, otherwise `_fzy_<cmd>` helpers or generic file search |

Requires `fzy`, `tac`, `xe`, and related tools noted at the top of `completion.zsh`.

### zsh-vi-mode defaults (not overridden)

These stay on the usual emacs-style Ctrl bindings in insert mode:

| Key | Action |
|---|---|
| **Ctrl+A / E** | Beginning / end of line |
| **Ctrl+B** | Backward char |
| **Ctrl+W** | Backward kill word |
| **Ctrl+K** | Kill to end of line |
| **Ctrl+U / Y** | Undo / yank |
| **Ctrl+P** | Previous line / history |
| **Ctrl+R / S** | Incremental history search |

**Ctrl+N** is rebound to sage cycle (see above) instead of down-line-or-history; use arrow keys or **Ctrl+P** for history navigation.

Custom sage/completion bindings are defined in `zvm_after_init` in `.zshrc` so `zsh-vi-mode` init does not override them.

## Notes

- Homebrew initialization in `.zshrc` is guarded (`brew` is optional), so Linux/WSL do not fail if Homebrew is absent.
- `.zshenv` sets `ZDOTDIR` to `~/.config/zsh`, so zsh reads `.zshrc` from this repo.
- `zsh-vi-mode` is enabled with insert mode as line default. Custom bindings are applied in `zvm_after_init` so plugin keymap initialization does not override sage and completion keys.

## License

Apache License 2.0. See `LICENSE`.
