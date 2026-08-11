# Dotfiles repository instructions

## Environment model

- Treat WSL as an independent Linux workstation.
- Prefer Linux executables and repositories under `~/dev` for Linux work.
- Do not introduce dependencies on `/mnt/c` or Windows executables unless a
  Windows-native workflow explicitly requires them.
- Keep Linux and Windows configuration separate where their behavior differs.
- Prefer separate Linux and Windows Git working copies for cross-platform work.

## Repository conventions

- Keep bootstrap behavior small, idempotent, and check-first.
- Back up conflicting user configuration before replacing or linking it.
- Track portable configuration, not credentials, caches, generated state,
  package-manager state, or project data.
- Prefer home-relative paths and explicit platform-specific configuration.
