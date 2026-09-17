#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
AUTO_YES=0
TEST_GITHUB=0
SSH_KEY="$HOME/.ssh/id_rsa"

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --yes|-y) AUTO_YES=1 ;;
        --test-github) TEST_GITHUB=1 ;;
        --key=*) SSH_KEY="${arg#--key=}" ;;
        *)
            echo "Usage: $0 [--dry-run] [--yes] [--key=/path/to/private-key] [--test-github]" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_TEMPLATE="$REPO_ROOT/migration/.gitconfig"
SSH_TEMPLATE="$REPO_ROOT/migration/ssh/config"
GIT_CONFIG="$HOME/.gitconfig"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
BACKUP_DIR="$HOME/.config/arching3-env-backup"
SSH_BEGIN="# >>> arching3-github-ssh >>>"
SSH_END="# <<< arching3-github-ssh <<<"

log() {
    printf '[install_migration_configs] %s\n' "$*"
}

fail() {
    printf '[install_migration_configs][error] %s\n' "$*" >&2
    exit 1
}

backup_file() {
    local file="$1"
    local name="$2"
    local timestamp

    [ -f "$file" ] || return
    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would back up $file"
        return
    fi

    timestamp="$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/${name}.${timestamp}.bak"
    log "backup created: $BACKUP_DIR/${name}.${timestamp}.bak"
}

upsert_ssh_block() {
    local temp

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would update the arching3 GitHub block in $SSH_CONFIG"
        return
    fi

    install -d -m 700 "$SSH_DIR"
    temp="$(mktemp)"
    if [ -f "$SSH_CONFIG" ]; then
        awk -v begin="$SSH_BEGIN" -v end="$SSH_END" '
            $0 == begin { skip = 1; next }
            $0 == end { skip = 0; next }
            !skip { print }
        ' "$SSH_CONFIG" > "$temp"
    fi
    {
        printf '\n'
        cat "$SSH_TEMPLATE"
    } >> "$temp"
    install -m 600 "$temp" "$SSH_CONFIG"
    rm -f "$temp"
    log "updated $SSH_CONFIG"
}

apply_global_git_identity() {
    local user_name
    local user_email

    command -v git >/dev/null 2>&1 || fail "git is required"
    user_name="$(git config --file "$GIT_TEMPLATE" --get user.name)"
    user_email="$(git config --file "$GIT_TEMPLATE" --get user.email)"
    [ -n "$user_name" ] || fail "missing user.name in $GIT_TEMPLATE"
    [ -n "$user_email" ] || fail "missing user.email in $GIT_TEMPLATE"

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would set global Git user.name to $user_name"
        log "dry-run: would set global Git user.email to $user_email"
        return
    fi

    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
    log "configured global Git identity"
}

check_ssh_key() {
    if [ ! -f "$SSH_KEY" ]; then
        log "SSH private key not found: $SSH_KEY"
        log "restore the existing private key securely or create a new key before GitHub authentication"
        return
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would set mode 600 on $SSH_KEY"
        return
    fi

    chmod 600 "$SSH_KEY"
    if [ -f "$SSH_KEY.pub" ]; then
        chmod 644 "$SSH_KEY.pub"
        ssh-keygen -lf "$SSH_KEY.pub" >/dev/null
        log "SSH key permissions and public-key format verified"
    else
        log "SSH private-key permissions set; public key file not found: $SSH_KEY.pub"
    fi
}

test_github_connection() {
    local ssh_output

    [ "$TEST_GITHUB" -eq 1 ] || return
    command -v ssh >/dev/null 2>&1 || fail "ssh is required"
    log "testing GitHub SSH authentication"
    ssh_output="$(ssh -o BatchMode=yes -T git@arching3.github.com 2>&1 || true)"
    if grep -q 'successfully authenticated' <<< "$ssh_output"; then
        log "GitHub SSH authentication succeeded"
    else
        log "GitHub SSH authentication was not confirmed; load the key with ssh-add and retry"
    fi
}

main() {
    [ -f "$GIT_TEMPLATE" ] || fail "missing template: $GIT_TEMPLATE"
    [ -f "$SSH_TEMPLATE" ] || fail "missing template: $SSH_TEMPLATE"

    if [ "$AUTO_YES" -ne 1 ] && [ "$DRY_RUN" -ne 1 ]; then
        printf 'Back up and update global Git identity and the arching3 SSH host block? [y/N] '
        read -r answer
        case "$answer" in
            y|Y|yes|YES) ;;
            *) log "aborted by user"; exit 0 ;;
        esac
    fi

    backup_file "$GIT_CONFIG" "gitconfig"
    backup_file "$SSH_CONFIG" "ssh-config"
    apply_global_git_identity
    upsert_ssh_block
    check_ssh_key
    test_github_connection
    log "done"
}

main "$@"
