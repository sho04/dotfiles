# Development environment

This repository is the source of truth for a Linux-first development
environment. WSL is treated as an independent Linux workstation; native
Windows remains a separate environment for Windows-specific SDKs, builds, and
graphics workflows.

Linux and Windows should use separate Git working copies. Windows-installed
Node, npm, Python, Git, compilers, and similar runtimes are not dependencies of
the WSL environment.

## Current configuration

- `nvim/` - shared Neovim 0.12 configuration
- `shell/` - Bash login, interactive, PATH, NVM, Zoxide, and direnv setup
- `config/git/` - portable Git defaults with a machine-local identity include
- `config/tmux/` - plugin-free tmux configuration tuned for Neovim
- `agents/` - shared global instructions for agent harnesses
- `config/codex/` - stable Codex defaults merged with machine-local state
- `config/opencode/` - minimal global OpenCode configuration
- `config/ponytail/` - shared Ponytail mode selection
- `packages/` - declarative Linux package and runtime selections
- `bootstrap.sh` - check-first Linux/WSL deployment

Windows-specific configuration can be added explicitly when needed rather
than mixed into the Linux files. Windows Terminal remains the host terminal;
the shell, multiplexer, editor, and development runtimes live in WSL.

## Bootstrap

Preview configuration links and tool resolution without making changes:

```bash
./bootstrap.sh --check
```

Apply configuration links:

```bash
./bootstrap.sh --apply
```

Apply the tracked WSL boundary as well:

```bash
./bootstrap.sh --apply --wsl
```

This disables automatic Windows PATH import while keeping WSL interop enabled.
The explicit `win-explorer` and `win-clip` wrappers cover the intentionally
allowed host integrations. Run `wsl --shutdown` from Windows after changing
`/etc/wsl.conf`.

Install declared packages and pinned runtimes as well:

```bash
./bootstrap.sh --apply --packages
```

Apply mode never deletes a conflicting target. Existing files are moved under
`~/.local/state/dotfiles/backups/<timestamp>/` before links are created.

The repository itself is exposed at `~/.config/dotfiles`, allowing tracked
configuration to refer to a stable home-relative location even if the clone is
moved.

## Agent harnesses

Codex and OpenCode share the deliberately small `agents/AGENTS.md` containing
personal defaults that make sense everywhere. Individual repositories add
specific guidance through their own `AGENTS.md`; this repository's root file
contains the detailed Linux/Windows environment boundary.

Codex runs with the `workspace-write` sandbox and `on-request` escalation. Its
tracked scalar defaults are merged into `~/.codex/config.toml` so project
trust, plugin state, hook approvals, authentication, and other machine-local
tables remain local. Existing Codex configuration is backed up before a merge.

OpenCode allows normal project actions without prompting and asks before
accessing external directories. Conversation sharing and automatic binary
updates are disabled. Package versions are managed by the bootstrap instead.

Ponytail defaults to `full`. Package installation registers a declared
Ponytail marketplace revision with Codex; OpenCode loads a pinned npm adapter
from the tracked configuration. The upstream Codex marketplace currently
resolves its plugin payload from its declared branch, so plugin state remains
locally visible rather than being treated as a tracked artifact. Codex requires
a new session after installation, and hooks must still be reviewed and trusted
interactively.

## Local Git identity

The tracked Git configuration includes `~/.config/git/config.local`. Bootstrap
preserves an existing local file or migrates the current global name and email
when first applying.

For a fresh machine, copy `local.example.env` to the ignored `local.env` and
set `DOTFILES_GIT_NAME` and `DOTFILES_GIT_EMAIL` before applying.

## Not tracked

Credentials, API keys, SSH material, AWS state, Docker authentication, Codex
and OpenCode authentication, caches, downloaded plugins, hook approvals,
package-manager state, SDKs, agent sessions/history, and project data do not
belong in this repository.
