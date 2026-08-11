# Dotfiles

- Treat WSL as standalone Linux; use Linux tools and repositories under `~/dev`.
- Use `/mnt/c` or Windows executables only for explicit native workflows.
- Keep platform-specific configuration and Git working copies separate.
- Keep bootstrap small, idempotent, check-first, and backup-safe.
- Track portable configuration only; never track secrets or generated state.
- Prefer home-relative paths.
