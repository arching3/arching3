if has('syntax')
  syntax on
endif

set nocompatible
filetype off
set number
set hlsearch
set incsearch
set ignorecase
set smartcase
set autoread
set hidden
set mouse=a
set laststatus=2
set updatetime=300
set signcolumn=yes

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set cindent
set smartindent

if has('termguicolors')
  set termguicolors
endif
set background=dark

autocmd FileType make setlocal noexpandtab

let mapleader = " "

function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-n>"
  endif
endfunction

inoremap <tab> <c-r>=InsertTabWrapper()<cr>

set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('~/.vim/bundle/Vundle.vim'))
  call vundle#begin()
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'tpope/vim-fugitive'
  Plugin 'tpope/vim-surround'
  Plugin 'tpope/vim-commentary'
  Plugin 'junegunn/fzf'
  Plugin 'junegunn/fzf.vim'
  Plugin 'preservim/nerdtree'
  Plugin 'airblade/vim-gitgutter'
  Plugin 'dense-analysis/ale'
  Plugin 'sheerun/vim-polyglot'
  Plugin 'rust-lang/rust.vim'
  call vundle#end()

  let g:everforest_background = 'soft'
  let g:everforest_better_performance = 1
  silent! colorscheme everforest
endif
filetype plugin indent on

nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :GFiles?<CR>
nnoremap <leader>b :Buffers<CR>

let g:ale_fix_on_save = 1
let g:ale_linters = {
\  'c': ['clangd'],
\  'cpp': ['clangd'],
\  'python': ['pyright'],
\  'rust': ['analyzer'],
\}
let g:ale_fixers = {
\  '*': ['trim_whitespace', 'remove_trailing_lines'],
\  'c': ['clang-format'],
\  'cpp': ['clang-format'],
\  'python': ['black'],
\  'rust': ['rustfmt'],
\}
