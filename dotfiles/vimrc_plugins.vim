if has('syntax')
  syntax on
endif
filetype plugin indent on

set nocompatible
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

if !empty(glob('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')
  Plug 'sainnhe/everforest'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'preservim/nerdtree'
  Plug 'airblade/vim-gitgutter'
  Plug 'dense-analysis/ale'
  Plug 'sheerun/vim-polyglot'
  Plug 'rust-lang/rust.vim'
  call plug#end()

  let g:everforest_background = 'soft'
  let g:everforest_better_performance = 1
  silent! colorscheme everforest
endif

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
