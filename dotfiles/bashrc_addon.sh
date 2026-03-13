# arching3 managed bash additions

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export XDG_SESSION_TYPE=x11
export CC=gcc
export CXX=g++

if [ -d "$HOME/.cargo/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.cargo/bin:"*) ;;
        *) export PATH="$HOME/.cargo/bin:$PATH" ;;
    esac
fi

if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

alias v='vim'
alias vi='vim'
alias cc='gcc'
alias cxx='g++'

alias gst='git status -sb'
alias gl='git log --oneline --graph --decorate -20'

alias cbuild='cmake -S . -B build -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Debug'
alias cbuildr='cmake -S . -B build -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Release'
alias cmb='cmake --build build -j"$(nproc)"'
alias ctestb='ctest --test-dir build --output-on-failure'

alias py='python3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'

alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cf='cargo fmt'
alias cl='cargo clippy --all-targets --all-features'

alias gccw='x86_64-w64-mingw32-gcc'
alias gxxw='x64_64-w64-mingw32-g++'

mkcd() {
    mkdir -p "$1" && cd "$1"
}
