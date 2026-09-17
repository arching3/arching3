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
set statusline=%<%F%h%m%r%=%-14.(%l,%c%V%)\ %P
set updatetime=300
set signcolumn=yes

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set cindent
set smartindent

" Python completion
let g:jedi#popup_select_first = 0
let g:jedi#completions_enabled = 1
let g:jedi#popup_on_dot = 0
let g:jedi#completions_command = ""
" Function/method signature help
let g:jedi#show_call_signatures = "2"

" Documentation
let g:jedi#documentation_command = "K"

" Navigation
let g:jedi#goto_command = "<leader>d"
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#usages_command = "<leader>u"
let g:jedi#rename_command = "<leader>r"

if has('termguicolors')
  set termguicolors
endif
set background=dark

autocmd FileType make setlocal noexpandtab
autocmd FileType python setlocal nocindent nosmartindent autoindent
autocmd FileType python setlocal completeopt-=preview
autocmd FileType python setlocal omnifunc=jedi#completions

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
nnoremap <Tab> >>
nnoremap <S-Tab> <<

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

let g:polyglot_disabled = ['python']

set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('~/.vim/bundle/Vundle.vim'))
  call vundle#begin()

  " plugin manager
  Plugin 'VundleVim/Vundle.vim'

  " ui and syntax
  Plugin 'sheerun/vim-polyglot'

  " python completion and syntax
  Plugin 'davidhalter/jedi-vim'

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
nnoremap K :LspHover<CR>
nnoremap gd :LspDefinition<CR>
nnoremap gr :LspReferences<CR>

let g:python_highlight_all = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 1
set synmaxcol=240
