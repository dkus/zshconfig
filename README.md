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

## Notes

- Homebrew initialization in `.zshrc` is guarded (`brew` is optional), so Linux/WSL do not fail if Homebrew is absent.
- `.zshenv` sets `ZDOTDIR` to `~/.config/zsh`, so zsh reads `.zshrc` from this repo.
- `zsh-vi-mode` is enabled with insert mode as line default. Custom bindings are applied in `zvm_after_init` so plugin keymap initialization does not override `zsh-sage` keys.

## License

Apache License 2.0. See `LICENSE`.
