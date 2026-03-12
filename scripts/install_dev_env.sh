#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
AUTO_YES=0
SKIP_PLUG_INSTALL=0
SKIP_VIM_PLUG=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --yes|-y) AUTO_YES=1 ;;
        --skip-plug-install) SKIP_PLUG_INSTALL=1 ;;
        --skip-vim-plug) SKIP_VIM_PLUG=1 ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [--dry-run] [--yes] [--skip-vim-plug] [--skip-plug-install]" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BASHRC="$HOME/.bashrc"
VIMRC="$HOME/.vimrc"
BASH_ADDON="$REPO_ROOT/dotfiles/bashrc_addon.sh"
VIM_PLUGIN_CONFIG="$REPO_ROOT/dotfiles/vimrc_plugins.vim"
BACKUP_DIR="$HOME/.config/arching3-env-backup"

BASH_BEGIN="# >>> arching3-dev-env >>>"
BASH_END="# <<< arching3-dev-env <<<"
VIM_BEGIN="\" >>> arching3-dev-env >>>"
VIM_END="\" <<< arching3-dev-env <<<"

log() {
    printf '[install_dev_env] %s\n' "$*"
}

fail() {
    printf '[install_dev_env][error] %s\n' "$*" >&2
    exit 1
}

require_file() {
    local file="$1"
    [ -f "$file" ] || fail "missing required file: $file"
}

backup_file() {
    local file="$1"
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/$(basename "$file").$ts.bak"
        log "backup created: $BACKUP_DIR/$(basename "$file").$ts.bak"
    else
        log "no existing file to backup: $file"
    fi
}

strip_managed_block() {
    local file="$1"
    local begin="$2"
    local end="$3"
    local out="$4"

    if [ -f "$file" ]; then
        awk -v begin="$begin" -v end="$end" '
            $0 == begin { skip = 1; next }
            $0 == end { skip = 0; next }
            !skip { print }
        ' "$file" > "$out"
    else
        : > "$out"
    fi
}

upsert_block_from_file() {
    local target_file="$1"
    local begin="$2"
    local end="$3"
    local content_file="$4"

    local tmp
    tmp="$(mktemp)"
    strip_managed_block "$target_file" "$begin" "$end" "$tmp"
    {
        printf '\n%s\n' "$begin"
        cat "$content_file"
        printf '%s\n' "$end"
    } >> "$tmp"
    mv "$tmp" "$target_file"
}

install_vim_plug() {
    local plug_path="$HOME/.vim/autoload/plug.vim"
    if [ -f "$plug_path" ]; then
        log "vim-plug already installed: $plug_path"
        return
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would install vim-plug into $plug_path"
        return
    fi

    log "installing vim-plug"
    if command -v curl >/dev/null 2>&1; then
        curl -fLo "$plug_path" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    elif command -v wget >/dev/null 2>&1; then
        mkdir -p "$(dirname "$plug_path")"
        wget -O "$plug_path" \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        fail "curl or wget is required to install vim-plug"
    fi
}

apply_changes() {
    require_file "$BASH_ADDON"
    require_file "$VIM_PLUGIN_CONFIG"

    local bash_block_file vim_block_file
    bash_block_file="$(mktemp)"
    vim_block_file="$(mktemp)"

    cat > "$bash_block_file" <<EOF
if [ -f "$BASH_ADDON" ]; then
    . "$BASH_ADDON"
fi
EOF

    cat > "$vim_block_file" <<EOF
if filereadable('$VIM_PLUGIN_CONFIG')
  execute 'source ' . fnameescape('$VIM_PLUGIN_CONFIG')
endif
EOF

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would update $BASHRC and $VIMRC with managed blocks"
    else
        backup_file "$BASHRC"
        backup_file "$VIMRC"
        upsert_block_from_file "$BASHRC" "$BASH_BEGIN" "$BASH_END" "$bash_block_file"
        upsert_block_from_file "$VIMRC" "$VIM_BEGIN" "$VIM_END" "$vim_block_file"
        log "managed blocks updated"
    fi

    rm -f "$bash_block_file" "$vim_block_file"
}

run_plug_install() {
    if [ "$SKIP_PLUG_INSTALL" -eq 1 ]; then
        log "skipping PlugInstall as requested"
        return
    fi

    if ! command -v vim >/dev/null 2>&1; then
        fail "vim is not installed"
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would run vim +PlugInstall +qall"
        return
    fi

    log "running PlugInstall"
    vim +PlugInstall +qall
}

main() {
    log "repo root: $REPO_ROOT"
    log "target bashrc: $BASHRC"
    log "target vimrc: $VIMRC"

    if [ "$AUTO_YES" -ne 1 ] && [ "$DRY_RUN" -ne 1 ]; then
        printf 'Apply managed settings to ~/.bashrc and ~/.vimrc? [y/N] '
        read -r answer
        case "$answer" in
            y|Y|yes|YES) ;;
            *) log "aborted by user"; exit 0 ;;
        esac
    fi

    apply_changes
    if [ "$SKIP_VIM_PLUG" -eq 1 ]; then
        log "skipping vim-plug bootstrap as requested"
    else
        install_vim_plug
    fi
    run_plug_install

    log "done"
    log "reload shell with: source ~/.bashrc"
}

main "$@"
