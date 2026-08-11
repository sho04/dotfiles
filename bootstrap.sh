#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly VERSIONS_FILE="$SCRIPT_DIR/packages/versions.env"
readonly LOCAL_ENV_FILE="$SCRIPT_DIR/local.env"

MODE="check"
INSTALL_PACKAGES=false
CONFIGURE_WSL=false
BACKUP_ROOT=""

usage() {
    cat <<'EOF'
Usage: ./bootstrap.sh [--check] [--apply] [--packages] [--wsl]

  --check      Report what would change (default).
  --apply      Back up conflicts and create configuration links.
  --packages   With --apply, install declared Linux tools and runtimes.
  --wsl        Configure WSL interop without importing the Windows PATH.
  --help       Show this message.

The script never deletes conflicting files. Apply mode moves them beneath
~/.local/state/dotfiles/backups before creating links.
EOF
}

log() {
    printf '[dotfiles] %s\n' "$*"
}

warn() {
    printf '[dotfiles] warning: %s\n' "$*" >&2
}

die() {
    printf '[dotfiles] error: %s\n' "$*" >&2
    exit 1
}

while (($#)); do
    case "$1" in
        --check) MODE="check" ;;
        --apply) MODE="apply" ;;
        --packages) INSTALL_PACKAGES=true ;;
        --wsl) CONFIGURE_WSL=true ;;
        --help|-h)
            usage
            exit 0
            ;;
        *) die "unknown argument: $1" ;;
    esac
    shift
done

if "$INSTALL_PACKAGES" && [ "$MODE" != "apply" ]; then
    die "--packages must be combined with --apply"
fi

# These files contain assignments only and are controlled by the repository
# owner. local.env is ignored by Git and may override identity values.
# shellcheck disable=SC1090
source "$VERSIONS_FILE"
if [ -r "$LOCAL_ENV_FILE" ]; then
    # shellcheck disable=SC1090
    source "$LOCAL_ENV_FILE"
fi

CURRENT_GIT_NAME="$(git config --global --get user.name 2>/dev/null || true)"
CURRENT_GIT_EMAIL="$(git config --global --get user.email 2>/dev/null || true)"
DOTFILES_GIT_NAME="${DOTFILES_GIT_NAME:-$CURRENT_GIT_NAME}"
DOTFILES_GIT_EMAIL="${DOTFILES_GIT_EMAIL:-$CURRENT_GIT_EMAIL}"

ensure_backup_root() {
    if [ -z "$BACKUP_ROOT" ]; then
        BACKUP_ROOT="$HOME/.local/state/dotfiles/backups/$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_ROOT"
    fi
}

backup_target() {
    local target="$1"
    local relative="${target#"$HOME"/}"
    local destination

    ensure_backup_root
    destination="$BACKUP_ROOT/$relative"
    mkdir -p "$(dirname -- "$destination")"
    mv -- "$target" "$destination"
    log "backed up $target -> $destination"
}

backup_copy() {
    local target="$1"
    local relative="${target#"$HOME"/}"
    local destination

    ensure_backup_root
    destination="$BACKUP_ROOT/$relative"
    mkdir -p "$(dirname -- "$destination")"
    cp -a -- "$target" "$destination"
    log "backed up $target -> $destination"
}

link_path() {
    local source="$1"
    local target="$2"
    local resolved=""

    [ -e "$source" ] || die "link source does not exist: $source"

    if [ -L "$target" ]; then
        resolved="$(readlink -f -- "$target" 2>/dev/null || true)"
        if [ "$resolved" = "$(readlink -f -- "$source")" ]; then
            log "ok: $target"
            return
        fi
    fi

    if [ "$MODE" = "check" ]; then
        if [ -e "$target" ] || [ -L "$target" ]; then
            log "would back up and link: $target"
        else
            log "would link: $target"
        fi
        return
    fi

    mkdir -p "$(dirname -- "$target")"
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_target "$target"
    fi
    ln -s -- "$source" "$target"
    log "linked $target -> $source"
}

configure_git_identity() {
    local target="$HOME/.config/git/config.local"

    if [ -e "$target" ]; then
        log "ok: $target (preserved local identity)"
        return
    fi

    if [ -z "$DOTFILES_GIT_NAME" ] || [ -z "$DOTFILES_GIT_EMAIL" ]; then
        warn "Git identity is unset; copy local.example.env to local.env before applying"
        return
    fi

    if [ "$MODE" = "check" ]; then
        log "would create untracked Git identity: $target"
        return
    fi

    mkdir -p "$(dirname -- "$target")"
    git config --file "$target" user.name "$DOTFILES_GIT_NAME"
    git config --file "$target" user.email "$DOTFILES_GIT_EMAIL"
    chmod 600 "$target"
    log "created local Git identity: $target"
}

configure_codex_defaults() {
    local defaults="$SCRIPT_DIR/config/codex/defaults.toml"
    local merger="$SCRIPT_DIR/scripts/merge-codex-config.awk"
    local target="$HOME/.codex/config.toml"
    local current="/dev/null"
    local candidate

    [ -e "$target" ] && current="$target"
    candidate="$(mktemp)"
    awk -f "$merger" "$defaults" "$current" > "$candidate"

    if [ -f "$target" ] && cmp -s -- "$candidate" "$target"; then
        rm -f -- "$candidate"
        log "ok: $target (tracked defaults present)"
        return
    fi

    if [ "$MODE" = "check" ]; then
        rm -f -- "$candidate"
        log "would merge tracked defaults into: $target"
        return
    fi

    mkdir -p "$(dirname -- "$target")"
    if [ -L "$target" ]; then
        backup_target "$target"
    elif [ -e "$target" ]; then
        backup_copy "$target"
    fi
    install -m 600 -- "$candidate" "$target"
    rm -f -- "$candidate"
    log "merged tracked defaults into: $target"
}

configure_wsl() {
    local template="$SCRIPT_DIR/config/wsl/wsl.conf.template"
    local target="/etc/wsl.conf"
    local candidate

    candidate="$(mktemp)"
    sed "s/@DEFAULT_USER@/$USER/g" "$template" > "$candidate"

    if [ -f "$target" ] && cmp -s -- "$candidate" "$target"; then
        rm -f -- "$candidate"
        log "ok: $target (Windows PATH import disabled)"
        return
    fi

    if [ "$MODE" = "check" ]; then
        rm -f -- "$candidate"
        log "would install WSL configuration: $target"
        return
    fi

    if [ -e "$target" ]; then
        ensure_backup_root
        sudo cp -a -- "$target" "$BACKUP_ROOT/etc-wsl.conf"
        log "backed up $target -> $BACKUP_ROOT/etc-wsl.conf"
    fi
    sudo install -m 644 -- "$candidate" "$target"
    rm -f -- "$candidate"
    log "installed $target; run 'wsl --shutdown' from Windows before testing"
}

manifest_lines() {
    awk 'NF && $1 !~ /^#/ { print }' "$1"
}

install_apt_packages() {
    local packages=()
    mapfile -t packages < <(manifest_lines "$SCRIPT_DIR/packages/apt.txt" | awk '{ print $1 }')
    log "installing ${#packages[@]} apt packages"
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
}

install_snap_packages() {
    local package confinement
    while read -r package confinement; do
        if snap list "$package" >/dev/null 2>&1; then
            log "snap already installed: $package"
            continue
        fi

        if [ "$confinement" = "classic" ]; then
            sudo snap install "$package" --classic
        else
            sudo snap install "$package"
        fi
    done < <(manifest_lines "$SCRIPT_DIR/packages/snap.txt")
}

install_nvm_and_node() {
    export NVM_DIR="$HOME/.nvm"

    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        [ ! -e "$NVM_DIR" ] || die "$NVM_DIR exists but does not contain nvm.sh"
        log "installing NVM $NVM_VERSION"
        git clone --filter=blob:none --branch "$NVM_VERSION" \
            https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    fi

    # shellcheck disable=SC1091
    source "$NVM_DIR/nvm.sh"
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
    nvm use "$NODE_VERSION"
}

install_npm_packages() {
    local package
    while read -r package; do
        npm install --global "$package"
    done < <(manifest_lines "$SCRIPT_DIR/packages/npm.txt")
}

install_codex_plugins() {
    command -v codex >/dev/null 2>&1 || die "Codex was not installed by npm"

    if codex plugin marketplace list 2>/dev/null | awk '$1 == "ponytail" { found = 1 } END { exit !found }'; then
        log "Codex marketplace already configured: ponytail"
    else
        codex plugin marketplace add DietrichGebert/ponytail --ref "$PONYTAIL_REVISION"
    fi

    if codex plugin list 2>/dev/null | awk '$1 == "ponytail@ponytail" && $2 ~ /^installed/ { found = 1 } END { exit !found }'; then
        log "Codex plugin already installed: ponytail@ponytail"
    else
        codex plugin add ponytail@ponytail
    fi
}

configure_rust() {
    command -v rustup >/dev/null 2>&1 || die "rustup was not installed by apt"
    rustup toolchain install "$RUST_TOOLCHAIN" \
        --profile minimal \
        --component rustfmt \
        --component rust-analyzer
    rustup default "$RUST_TOOLCHAIN"

    if [ -r "$HOME/.cargo/env" ]; then
        # shellcheck disable=SC1091
        source "$HOME/.cargo/env"
    fi
}

install_cargo_packages() {
    local package version
    while read -r package version; do
        cargo install --locked --version "$version" "$package"
    done < <(manifest_lines "$SCRIPT_DIR/packages/cargo.txt")
}

check_tools() {
    local tool
    local path
    local tools=(bash git nvim tmux node npm codex opencode cargo rustc zoxide tree-sitter rg fdfind fzf jq batcat direnv shellcheck cmake bwrap docker dotnet)

    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            path="$(command -v "$tool")"
            case "$path" in
                /mnt/*)
                    printf '[dotfiles] tool: %-12s %s %s\n' "$tool" "WINDOWS PATH LEAK:" "$path"
                    ;;
                *)
                    printf '[dotfiles] tool: %-12s %s\n' "$tool" "$path"
                    ;;
            esac
        else
            printf '[dotfiles] tool: %-12s %s\n' "$tool" "missing"
        fi
    done
}

apply_links() {
    link_path "$SCRIPT_DIR" "$HOME/.config/dotfiles"
    link_path "$SCRIPT_DIR/shell/bashrc" "$HOME/.bashrc"
    link_path "$SCRIPT_DIR/shell/profile" "$HOME/.profile"
    link_path "$SCRIPT_DIR/config/git/config" "$HOME/.gitconfig"
    link_path "$SCRIPT_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    link_path "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
    link_path "$SCRIPT_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
    link_path "$SCRIPT_DIR/agents/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
    link_path "$SCRIPT_DIR/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    link_path "$SCRIPT_DIR/config/ponytail/config.json" "$HOME/.config/ponytail/config.json"
    link_path "$SCRIPT_DIR/bin/win-explorer" "$HOME/.local/bin/win-explorer"
    link_path "$SCRIPT_DIR/bin/win-clip" "$HOME/.local/bin/win-clip"
    configure_git_identity
    configure_codex_defaults
}

install_packages() {
    install_apt_packages
    install_snap_packages
    install_nvm_and_node
    install_npm_packages
    install_codex_plugins
    configure_rust
    install_cargo_packages
}

log "mode: $MODE"
apply_links

if "$CONFIGURE_WSL"; then
    configure_wsl
fi

if "$INSTALL_PACKAGES"; then
    install_packages
else
    check_tools
fi

if [ -n "$BACKUP_ROOT" ]; then
    log "backups retained at $BACKUP_ROOT"
fi

if [ "$MODE" = "check" ]; then
    log "check complete; no changes were made"
else
    log "apply complete; restart Bash and tmux to load the tracked configuration"
fi
