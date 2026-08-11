# Merge tracked top-level scalar defaults into a Codex config while preserving
# machine-local tables such as projects, marketplaces, plugins, and hook state.
NR == FNR {
    if ($0 ~ /^[[:space:]]*#/ || $0 ~ /^[[:space:]]*$/) {
        next
    }

    key = $0
    sub(/[[:space:]]*=.*/, "", key)
    order[++count] = key
    desired[key] = $0
    next
}

function emit_missing(    i, key) {
    emitted = 0
    for (i = 1; i <= count; i++) {
        key = order[i]
        if (!seen[key]) {
            print desired[key]
            seen[key] = 1
            emitted = 1
        }
    }
}

{
    if (!in_table && $0 ~ /^[[:space:]]*\[/) {
        emit_missing()
        if (emitted) {
            print ""
        }
        in_table = 1
    }

    if (!in_table && $0 ~ /^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*=/) {
        key = $0
        sub(/^[[:space:]]*/, "", key)
        sub(/[[:space:]]*=.*/, "", key)
        if (key in desired) {
            print desired[key]
            seen[key] = 1
            next
        }
    }

    print
}

END {
    if (!in_table) {
        emit_missing()
    }
}
