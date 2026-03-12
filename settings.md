# Vim/Bash 환경 표준안 (C/C++, Python, Rust)

이 문서는 `arching3` 저장소를 기준으로 개발 환경을 재현하기 위한 권장 설정입니다.

## 목표
- 매번 수동으로 `.bashrc`, `.vimrc`, 플러그인을 다시 세팅하지 않도록 자동화
- 기존 `~/.bashrc`, `~/.vimrc`는 유지하면서 **관리 블록만 삽입** (안전한 방식)
- C/C++, Python, Rust 개발에 필요한 최소/실용 플러그인 구성

## 추천 Vim 플러그인
- `VundleVim/Vundle.vim`: 플러그인 매니저 (bundle 기반)
- `sheerun/vim-polyglot`: 언어별 문법/indent 강화
- `tpope/vim-fugitive`: Git 통합
- `airblade/vim-gitgutter`: Git 변경 라인 표시
- `tpope/vim-surround`: 괄호/따옴표 편집
- `tpope/vim-commentary`: 주석 토글
- `michaeljsmith/vim-indent-object`: indent 단위 text-object(`ai`, `ii`) 제공
- `junegunn/vim-easy-align`: 텍스트 정렬(`:EasyAlign`) 지원
- `preservim/nerdtree`: 파일 트리
- `Xuyuanp/nerdtree-git-plugin`: NERDTree에서 Git 상태 표시
- `octol/vim-cpp-enhanced-highlight`: C/C++ 하이라이트 보강
- `vim-python/python-syntax`: Python 문법 하이라이트 보강
- `rust-lang/rust.vim`: Rust 지원 보강

## Colorscheme (GitHub 직접 설치)
- `everforest`를 Vundle이 아닌 GitHub clone으로 설치/적용
- 설치 경로: `~/.vim/pack/colors/start/everforest`
- 원격 저장소: `https://github.com/sainnhe/everforest.git`

## 언어 도구 권장
- C/C++: `gcc`, `g++`, `gdb`, `make`/`cmake` (선택: `clangd`, `clang-format`)
- Python: `black` (선택적으로 `ruff`)
- Rust: `rust-analyzer`, `rustfmt`, `clippy`

## Bash 권장 추가 설정
- 기본 편집기: `EDITOR=vim`, `VISUAL=vim`
- C/C++ 기본 컴파일러: `CC=gcc`, `CXX=g++`
- PATH 보강: `~/.cargo/bin`, `~/.local/bin`
- 생산성 alias:
  - C/C++: `cbuild`, `cbuildr`, `cmb`, `ctestb`
  - Python: `py`, `venv`
  - Rust: `cb`, `cr`, `ct`, `cf`, `cl`
  - Git: `gst`, `gl`
- 유틸 함수: `mkcd`

## 적용 방식
설치 스크립트는 다음을 수행합니다.
1. `~/.bashrc`, `~/.vimrc` 백업 생성
2. 두 파일에 `arching3` 관리 블록을 삽입/갱신 (중복 없이 재실행 가능)
3. `~/.vim/bundle/Vundle.vim` 자동 설치 (없을 때만)
4. GitHub에서 `everforest` colorscheme clone/업데이트
5. `vim +PluginInstall +qall` 실행

## 파일 구성
- `dotfiles/bashrc_addon.sh`: Bash 추가 설정 본문
- `dotfiles/vimrc_plugins.vim`: Vim 옵션 + 플러그인 목록 + 언어 설정
- `scripts/install_dev_env.sh`: 자동 설치 스크립트

## 승인 후 실행 명령
먼저 미리보기:

```bash
cd /home/arching/arching3
./scripts/install_dev_env.sh --dry-run
```

적용:

```bash
cd /home/arching/arching3
./scripts/install_dev_env.sh --yes
```

병합만 먼저(플러그인 매니저/플러그인 설치 제외):

```bash
cd /home/arching/arching3
./scripts/install_dev_env.sh --yes --skip-vundle --skip-plugin-install
```

적용 후 반영:

```bash
source ~/.bashrc
vim
```
