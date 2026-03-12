# Vim Plugin Usage

이 문서는 `dotfiles/vimrc_plugins.vim` 기준 플러그인 사용법 요약입니다.

## 빠른 시작
- 플러그인 설치: `:PluginInstall`
- 플러그인 업데이트: `:PluginUpdate`
- 미사용 플러그인 정리: `:PluginClean`
- 설정 다시 로드: `:source ~/.vimrc`

## 1) Vundle (`VundleVim/Vundle.vim`)
- 플러그인 관리용 매니저입니다.
- 플러그인 목록 변경 후 `:PluginInstall` 실행.

## 2) vim-polyglot (`sheerun/vim-polyglot`)
- 언어별 syntax/indent를 자동으로 보강합니다.
- 별도 명령 없이 파일 열면 바로 적용됩니다.

## 3) vim-fugitive (`tpope/vim-fugitive`)
- `:Git status` 또는 `:Git`
- `:Gdiffsplit`
- `:Gblame`
- `:Gwrite` (현재 파일 stage)

## 4) vim-gitgutter (`airblade/vim-gitgutter`)
- 변경 라인을 sign column에 표시합니다.
- 다음/이전 hunk 이동: `]c`, `[c`
- 현재 hunk 미리보기: `:GitGutterPreviewHunk`
- 현재 hunk stage: `:GitGutterStageHunk`
- 현재 hunk 되돌리기: `:GitGutterUndoHunk`

## 5) vim-surround (`tpope/vim-surround`)
- 단어를 따옴표로 감싸기: `ysiw"`
- 기존 둘러싸기 변경: `cs"'`
- 둘러싸기 삭제: `ds"`

## 6) vim-commentary (`tpope/vim-commentary`)
- 현재 줄 주석 토글: `gcc`
- 범위 주석: `gc` + motion (예: `gcap`, `gcj`)
- 비주얼 선택 후 `gc`

## 7) vim-indent-object (`michaeljsmith/vim-indent-object`)
- 현재 indent 블록 선택(outer): `vai`
- 현재 indent 블록 선택(inner): `vii`
- 텍스트 객체로 삭제/변경 가능: `dai`, `cii`

## 8) vim-easy-align (`junegunn/vim-easy-align`)
- 기본 명령: `:EasyAlign {delimiter}`
- 예시: `:EasyAlign =`
- 비주얼 선택 후 실행하면 선택 범위 정렬.
- 필요하면 개인 매핑 추가:
  - `xmap ga <Plug>(EasyAlign)`
  - `nmap ga <Plug>(EasyAlign)`

## 9) NERDTree (`preservim/nerdtree`)
- 토글 키: `<leader>n` (현재 설정)
- 직접 명령: `:NERDTreeToggle`
- 파일 포커스: `:NERDTreeFind`

## 10) nerdtree-git-plugin (`Xuyuanp/nerdtree-git-plugin`)
- NERDTree 안에서 Git 상태 아이콘을 표시합니다.
- 별도 명령 없이 NERDTree와 함께 동작합니다.

## 11) fzf / fzf.vim (`junegunn/fzf`, `junegunn/fzf.vim`)
- 파일 검색: `<leader>f` (`:Files`)
- Git tracked 파일 검색: `<leader>g` (`:GFiles?`)
- 버퍼 목록: `<leader>b` (`:Buffers`)
- 전체 검색(옵션): `:Rg {pattern}` (`rg` 설치 시)

## 12) ALE (`dense-analysis/ale`)
- 현재 설정: 입력 중/Insert 종료 시 실시간 lint, 저장 시 자동 fix.
- 에러/경고 표시는 sign column(`E`, `W`)에 출력.
- 상태 확인: `:ALEInfo`
- 현재 진단 상세: `:ALEDetail`
- 수동 fix 실행: `:ALEFix`

## 13) C/C++ highlight (`octol/vim-cpp-enhanced-highlight`)
- C/C++ 문법 하이라이트를 강화합니다.
- 별도 명령 없이 `.c/.cpp/.h/.hpp`에서 자동 적용됩니다.

## 14) Python syntax (`vim-python/python-syntax`)
- Python 문법 하이라이트를 강화합니다.
- 별도 명령 없이 `.py`에서 자동 적용됩니다.

## 15) rust.vim (`rust-lang/rust.vim`)
- Rust filetype 지원을 제공합니다.
- 현재 설정에선 저장 시 ALE가 `rustfmt` fixer를 실행합니다.

## Colorscheme
- colorscheme은 Vundle이 아니라 GitHub clone으로 설치합니다.
- 현재 설정: `everforest`
- 설치 경로: `~/.vim/pack/colors/start/everforest`
