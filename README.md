# Dotfiles

Linux-first development environment for WSL. Windows remains separate for
native tools and builds.

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

Neovim uses OneDark Pro's `onedark_dark` theme by default. Set
`NVIM_ONEDARK_STYLE` to `onedark`, `onedark_dark`, `onedark_vivid`, `onelight`,
or `vaporwave` before starting Neovim to try another variant.

After setup, install configured Neovim tools and parsers:

```vim
:MasonToolsInstall
:TSInstallConfigured
```

The native multiplexer is psmux. Its config is intentionally separate from the
Linux tmux config because psmux implements only a subset of tmux options.

## WSL setup

```bash
./bootstrap.sh --check
./bootstrap.sh --apply --packages --wsl
```

Then run `wsl --shutdown` from Windows. WSL repositories and tools stay under
`~/dev`; native Windows work stays in its own checkout.

For Git identity, copy `local.example.env` to the ignored `local.env` before
applying. Conflicts are backed up under `~/.local/state/dotfiles/backups/`.

Install Neovim tools and parsers with `:MasonToolsInstall` and
`:TSInstallConfigured`.

Neovim is linked directly from `~/.config/nvim` to this repo's `nvim/` directory;
restart Neovim after editing it. Select a Nerd Font in your terminal for icons
(font size and line spacing are terminal settings).

Navigation uses Space as the leader:

- `Space e`: file tree popup; `Space E`: reveal the current file in the popup.
- `-`: open the current file's directory in an Oil popup; Enter opens an entry, `-` goes
  up a directory. Edit names or add entries, then `:w` to review and apply file
  operations. `q` or Escape in normal mode closes either explorer popup.
  Opening a directory at startup sets the working directory without opening an explorer.
- `Space eb` / `Space eg`: open buffers / Git changes.
- `Space es`: symbol outline (requires an attached language server).
- `Space ff` / `Space fg`: find files / search project text.
- `Space fo`: recent files under the current working directory; `Space fr`: resume the last search.
- `Space fs` / `Space fS`: file / workspace symbols (requires a language server).
- `[b` / `]b`: previous / next buffer.
- `Space fb`: search open buffers; `Space bd`: close the current buffer.
- `Space wv` / `Space ws`: split side by side / top and bottom.
- `Space wh` / `Space wj` / `Space wk` / `Space wl`: focus left / down / up / right.
- `Space wq`: close the split; `Space w=`: equalize split sizes.
- `Space tc`: toggle sticky function/class context (requires a Treesitter parser).

Sessions save automatically on exit after opening a file, under
`~/.local/state/nvim/sessions/`, separately for each working directory and Git
branch. They restore file buffers, window layout, and cursor positions, not
unsaved edits or running terminal processes. Start Neovim from the project root
and press `Space qs` to restore that project's session. `Space qS` selects a
session, `Space ql` restores the last session, and `Space qd` skips saving on exit.
Restoring is always explicit; session files stay outside the repository.
