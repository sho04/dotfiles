# Dotfiles

Windows-first native development environment with a separate Linux setup for
WSL. Shared editor and tool configuration lives in this repository, while
platform-specific shell and multiplexer configuration remains separate.

## Windows setup

Run from PowerShell in a native Windows checkout:

```powershell
.\bootstrap.ps1 -Check
.\bootstrap.ps1 -Apply
# Optional tool installation:
.\bootstrap.ps1 -Apply -Packages
```

The bootstrap uses a directory junction for Neovim and hard links for managed
files, backs up conflicts under `%LOCALAPPDATA%\dotfiles\backups`, and preserves
local Git identity. Keep the checkout and your user profile on the same drive.
Copy `local.example.env` to the ignored `local.env` to set Git identity.

Neovim uses OneDark's `darker` style by default. Set `NVIM_ONEDARK_STYLE` to
`dark`, `darker`, `cool`, `deep`, `warm`, or `warmer` before starting Neovim to
try another variant.

After setup, install configured Neovim tools and parsers:

```vim
:MasonToolsInstall
:TSInstallConfigured
```

The native multiplexer is psmux. Its config is intentionally separate from the
Linux tmux config because psmux implements only a subset of tmux options.

## WSL setup

Run inside the standalone Linux checkout:

```bash
./bootstrap.sh --check
./bootstrap.sh --apply --packages --wsl
```

Then run `wsl --shutdown` from Windows. WSL repositories and tools stay under
`~/dev`; native Windows work stays in its own checkout.
