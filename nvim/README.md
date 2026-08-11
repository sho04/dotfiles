# Neovim configuration

This is the shared Neovim configuration for Linux/WSL and native Windows. It
requires Neovim 0.12 or newer and deliberately avoids Nerd Font icons.

The host bootstrap will need to provide Git, curl, tar, CMake, a C compiler,
`tree-sitter-cli` 0.26.1 or newer, and the language runtimes used by projects.
In particular, Roslyn requires a native .NET SDK in each environment; the WSL
configuration must not fall back to Windows `dotnet.exe`.

The configuration does not install tools during normal startup. After the
plugin set has been synchronized, provision editor tooling explicitly:

```vim
:MasonToolsInstall
:TSInstallConfigured
```

Use the bang form of the Treesitter command during a headless bootstrap when
the install must finish before Neovim exits:

```vim
:TSInstallConfigured!
```

`lazy-lock.json` is part of the source of truth. Generate it with the first
intentional `:Lazy sync`, review it, and commit it. Lazy, Mason, parser, cache,
swap, undo, and ShaDa data belong in Neovim's standard data/state directories,
not this repository.

## Formatting

Supported files format on save. The following controls are available:

- `:FormatDisable` disables format-on-save for the current buffer.
- `:FormatDisable!` disables it for the current Neovim session.
- `:FormatEnable` and `:FormatEnable!` reverse those settings.
- A `.nvim-disable-format` file anywhere at or above a project buffer disables
  format-on-save for that project.

Project formatter configuration and `.editorconfig` files take precedence over
the personal defaults in this directory.

## Terminals

tmux owns long-running shells, servers, logs, and workspace persistence.
Neovim's built-in terminal remains available for quick tasks through
`<leader>tt` and `<leader>tv`; there is no terminal plugin.
