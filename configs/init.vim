"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" VUNDLE PLUGIN PART

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo

Plugin 'altercation/vim-colors-solarized'
Plugin 'bling/vim-airline'
Plugin 'bling/vim-bufferline'

Plugin 'ivalkeen/nerdtree-execute'

Plugin 'majutsushi/tagbar'

Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'

Plugin 'pyflakes/pyflakes'

Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append  to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append  to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append  to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Options

"solarized plugin
set background=dark
syntax on
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
let g:solarized_termtrans = 1
let g:solarized_termcolors = 256
colorscheme solarized

"NERDTree plugin
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <C-n>v :NERDTreeToggle<CR>

"latex conf
set grepprg=grep\ -nH\
let g:tex_flavor='latex'


"filetype off
filetype plugin indent on
"else
set nocompatible
set nomodeline

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
"set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set undofile
set number

let mapleader = ","

nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
"nnoremap <tab> %
"vnoremap <tab> %

set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85

set list
set listchars=tab:▸\ ,eol:¬

nnoremap j gj
nnoremap k gk

inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

nnoremap ; :

au FocusLost * :wa


"set smarttab
set viminfo='20,\"50
set history=50
"set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set autowrite
set mouse=a
set guioptions=aegirL

set pastetoggle=<F2>
inoremap <C-v> <F2><C-r>+<F2>
vnoremap <C-c> "+y

set fileencodings=utf-8,cp1251,koi8-r

""" Open each of requested files in new tab
autocmd VimEnter * nested if argc() > 1 && !&diff | tab sball | tabfirst | endif

if !has('nvim')
    set ttymouse=xterm2
endif

augroup vimrc
  " Automatically delete trailing DOS-returns and whitespace on file open
  " and write.
    autocmd BufRead,BufWritePre,FileWritePre * silent! %s/[\r \t]\+$//
augroup END

