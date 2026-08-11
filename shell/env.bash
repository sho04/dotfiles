_dotfiles_path_prepend() {
    local directory="$1"
    local entry
    local rebuilt=""
    local entries=()

    [ -d "$directory" ] || return 0

    IFS=: read -r -a entries <<< "${PATH:-}"
    for entry in "${entries[@]}"; do
        [ -n "$entry" ] || continue
        [ "$entry" = "$directory" ] && continue
        rebuilt="${rebuilt:+$rebuilt:}$entry"
    done

    export PATH="$directory${rebuilt:+:$rebuilt}"
}

_dotfiles_path_prepend "$HOME/bin"
_dotfiles_path_prepend "$HOME/.cargo/bin"
_dotfiles_path_prepend "$HOME/.local/bin"

unset -f _dotfiles_path_prepend

export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-FRX"
