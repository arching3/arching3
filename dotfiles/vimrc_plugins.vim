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

  " plugin manager
  Plugin 'VundleVim/Vundle.vim'

  " ui and syntax
  Plugin 'sheerun/vim-polyglot'

  " git workflow
  Plugin 'tpope/vim-fugitive'
  Plugin 'airblade/vim-gitgutter'

  " editing ergonomics
  Plugin 'tpope/vim-surround'
  Plugin 'tpope/vim-commentary'
  Plugin 'michaeljsmith/vim-indent-object'
  Plugin 'junegunn/vim-easy-align'

  " file tree
  Plugin 'preservim/nerdtree'
  Plugin 'Xuyuanp/nerdtree-git-plugin'

  " language focused additions
  Plugin 'octol/vim-cpp-enhanced-highlight'
  Plugin 'vim-python/python-syntax'
  Plugin 'rust-lang/rust.vim'

  call vundle#end()
endif
filetype plugin indent on

" colorscheme is installed from GitHub directly (not via Vundle)
if isdirectory(expand('~/.vim/pack/colors/start/everforest'))
  silent! colorscheme everforest
endif

nnoremap <leader>n :NERDTreeToggle<CR>
