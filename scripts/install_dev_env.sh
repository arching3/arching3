#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
AUTO_YES=0
SKIP_PLUGIN_INSTALL=0
SKIP_VUNDLE=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --yes|-y) AUTO_YES=1 ;;
        --skip-plugin-install|--skip-plug-install) SKIP_PLUGIN_INSTALL=1 ;;
        --skip-vundle|--skip-vim-plug) SKIP_VUNDLE=1 ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [--dry-run] [--yes] [--skip-vundle] [--skip-plugin-install]" >&2
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

COLORSCHEME_NAME="everforest"
COLORSCHEME_REPO_URL="https://github.com/sainnhe/everforest.git"
COLORSCHEME_DIR="$HOME/.vim/pack/colors/start/$COLORSCHEME_NAME"

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

install_vundle() {
    local vundle_path="$HOME/.vim/bundle/Vundle.vim"
    if [ -d "$vundle_path" ]; then
        log "Vundle already installed: $vundle_path"
        return
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would install Vundle into $vundle_path"
        return
    fi

    command -v git >/dev/null 2>&1 || fail "git is required to install Vundle"
    mkdir -p "$HOME/.vim/bundle"
    log "installing Vundle"
    git clone https://github.com/VundleVim/Vundle.vim.git "$vundle_path"
}

install_colorscheme_from_github() {
    if [ -d "$COLORSCHEME_DIR/.git" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
            log "dry-run: would update colorscheme $COLORSCHEME_NAME in $COLORSCHEME_DIR"
            return
        fi

        command -v git >/dev/null 2>&1 || fail "git is required to update colorscheme"
        log "updating colorscheme $COLORSCHEME_NAME"
        git -C "$COLORSCHEME_DIR" pull --ff-only || log "colorscheme update skipped (pull failed)"
        return
    fi

    if [ -d "$COLORSCHEME_DIR" ]; then
        log "colorscheme directory exists (non-git), skipping clone: $COLORSCHEME_DIR"
        return
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would clone colorscheme $COLORSCHEME_NAME from $COLORSCHEME_REPO_URL"
        return
    fi

    command -v git >/dev/null 2>&1 || fail "git is required to install colorscheme"
    mkdir -p "$(dirname "$COLORSCHEME_DIR")"
    log "cloning colorscheme $COLORSCHEME_NAME from GitHub"
    git clone "$COLORSCHEME_REPO_URL" "$COLORSCHEME_DIR"
}

apply_changes() {
    require_file "$BASH_ADDON"
    require_file "$VIM_PLUGIN_CONFIG"

    local bash_block_file vim_block_file
    bash_block_file="$(mktemp)"
    vim_block_file="$(mktemp)"

    cat > "$bash_block_file" <<EOF2
if [ -f "$BASH_ADDON" ]; then
    . "$BASH_ADDON"
fi
EOF2

    cat > "$vim_block_file" <<EOF2
if filereadable('$VIM_PLUGIN_CONFIG')
  execute 'source ' . fnameescape('$VIM_PLUGIN_CONFIG')
endif
EOF2

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

run_plugin_install() {
    if [ "$SKIP_PLUGIN_INSTALL" -eq 1 ]; then
        log "skipping PluginInstall as requested"
        return
    fi

    if ! command -v vim >/dev/null 2>&1; then
        fail "vim is not installed"
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "dry-run: would run vim +PluginInstall +qall"
        return
    fi

    log "running PluginInstall"
    vim +PluginInstall +qall

    local fzf_installer="$HOME/.vim/bundle/fzf/install"
    if [ -x "$fzf_installer" ]; then
        log "installing fzf binary"
        "$fzf_installer" --all
    else
        log "fzf installer not found; skipping fzf binary install"
    fi
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
    if [ "$SKIP_VUNDLE" -eq 1 ]; then
        log "skipping Vundle bootstrap as requested"
    else
        install_vundle
    fi
    install_colorscheme_from_github
    run_plugin_install

    log "done"
    log "reload shell with: source ~/.bashrc"
}

main "$@"
