# Dotfiles

Linux-first development environment for WSL. Windows remains separate for
native tools and builds.

## Setup

```bash
./bootstrap.sh --check
./bootstrap.sh --apply --packages --wsl
```

Then run `wsl --shutdown` from Windows.

For Git identity, copy `local.example.env` to the ignored `local.env` before
applying. Conflicts are backed up under `~/.local/state/dotfiles/backups/`.

Install Neovim tools and parsers with `:MasonToolsInstall` and
`:TSInstallConfigured`.
