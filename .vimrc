let $LD_LIBRARY_PATH=''
set rtp^=~/.vim
set rtp^=~/.vim/after

""""""""""""""""""""""""""""""
"Vundle
""""""""""""""""""""""""""""""
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin('~/.vim_runtime/bundle')

Plugin 'VundleVim/Vundle.vim'               " plugin manager
Plugin 'majutsushi/Tagbar'                  " Displays tags in a sidebar
Plugin 'vim-airline/vim-airline'            " status/tabline
Plugin 'vim-airline/vim-airline-themes'     " vim airline themes
Plugin 'tpope/vim-fugitive'                 " git wrapper
Plugin 'scrooloose/nerdtree'                " file browser
Plugin 'jistr/vim-nerdtree-tabs'            " nerdtree and tabs together
Plugin 'scrooloose/syntastic'               " syntax checker
Plugin 'nvie/vim-flake8'                    " python syntax & style checker
Plugin 'tpope/vim-surround'                 " mappings to easily delete, change and add such surroundings in pairs
Plugin 'kien/ctrlp.vim'                     " Full path fuzzy file, buffer, mru, tag finder
Plugin 'easymotion/vim-easymotion'          " easy movement
Plugin 'sickill/vim-pasta'                  " pasting in vim with indentation adjusted
Plugin 'terryma/vim-multiple-cursors'       " sublime-text style multiple cursors
Plugin 'xolox/vim-misc'                     " auto-load vim scripts
Plugin 'scrooloose/nerdcommenter'           " intensely orgasmic commenting
Plugin 'flazz/vim-colorschemes'             " color schemes
Plugin 'qualiabyte/vim-colorstepper'        " cycle through color schemes
Plugin 'godlygeek/csapprox'                 " make gvim only coloschemes work transparently in terminal vim
Plugin 'octol/vim-cpp-enhanced-highlight'   " cpp enhanced syntax highlights

call vundle#end()

filetype plugin indent on

""""""""""""""""""""""""""""""
"Tagbar
""""""""""""""""""""""""""""""
nmap <F8> :TagbarToggle<CR>

""""""""""""""""""""""""""""""
"NerdTree
""""""""""""""""""""""""""""""
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>

""""""""""""""""""""""""""""""
"Syntastic
""""""""""""""""""""""""""""""
let g:syntastic_cpp_compiler_options = '-std=c++14 -Wall -Wextra'

""""""""""""""""""""""""""""""
" Vim-Airline
""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:airline#extensions#tabline#enabled = 1

let g:airline_detect_modified=1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#branch#empty_message = ''

let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tagbar#enabled = 1

let g:airline#extensions#wordcount#enabled = 1

let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>+ <Plug>AirlineSelectNextTab

""""""""""""""""""""""""""""""
"Miscellaneous
""""""""""""""""""""""""""""""

" General
""""""""""""""""""""""""""""""
set history=1000
set autoread
set mouse=a
set hidden
set noshowmode
set noerrorbells
set novisualbell
set timeoutlen=500
set splitbelow
set splitright
set exrc
set secure

" Indent and tab
""""""""""""""""""""""""""""""
set foldcolumn=1
set foldlevelstart=99
set foldmethod=indent
set autoindent
set cindent
set shiftwidth=4
set expandtab
set smarttab
set tabstop=4
set softtabstop=4
filetype plugin indent on

" persistent undo
""""""""""""""""""""""""""""""
try
    silent !mkdir -p ~/.vim/temp_dirs/undodir >/dev/null 2>&1
    set undodir=~/.vim/temp_dirs/undodir
    set undofile
catch
endtry

" paste mode
""""""""""""""""""""""""""""""
nnoremap <F2> :set invpaste paste?<cr>
set pastetoggle=<F2>

command Ev tabedit $MYVIMRC
command Sv source $MYVIMRC

command ToggleColorColumn if &colorcolumn == "" | setlocal colorcolumn=81 | else | setlocal colorcolumn= | endif
map <A-c> :ToggleColorColumn<CR>

" Toggle folding
""""""""""""""""""""""""""""""
nnoremap <space> za

" Encoding
""""""""""""""""""""""""""""""
nnoremap <space> za
set encoding=utf-8
set fileformats=unix,dos
set fileformat=unix

" Cursor always in the center
""""""""""""""""""""""""""""""
set so=999

" Navigation shortcuts
""""""""""""""""""""""""""""""
" treat long lines as multiple lines
map j gj
map k gk

nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Switch between tabs
nnoremap <C-j> :tabprevious<CR>
nnoremap <C-k> :tabnext<CR>

" Move tabs
nnoremap <silent> <A-i> :execute 'silent! tabmove ' . (tabpagenr() - 2)<CR>
nnoremap <silent> <A-o> :execute 'silent! tabmove ' . (tabpagenr() + 1)<CR>

if has ('nvim')
    tmap <A-h> <C-\><C-n><C-w>h
    tmap <A-j> <C-\><C-n><C-w>j
    tmap <A-k> <C-\><C-n><C-w>k
    tmap <A-l> <C-\><C-n><C-w>l
    tmap <A-i> <C-\><C-n>:execute "tabmove" tabpagenr() - 2 <CR>
    tmap <A-o> <C-\><C-n>:execute "tabmove" tabpagenr() + 1 <CR>
endif

" UI
""""""""""""""""""""""""""""""
set t_Co=256
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
syntax on
colorscheme wombat256i

" http://www.nerdyweekly.com/posts/enable-italic-text-vim-tmux-gnome-terminal/
" tutorial to enable italics
highlight Todo cterm=bold,underline
highlight Function cterm=bold
highlight Normal ctermfg=256 ctermbg=none
highlight Comments cterm=italic
highlight Strings cterm=italic

set ruler
set showcmd
set number
set scrolloff=8
set report=0
set shortmess+=I
set list
set listchars=tab:»\ ,trail:·,extends:»,precedes:«
set wildmenu
set wildmode=list:longest

" ignore compiled files and executables
"""""""""""""""""""""""""""""""""""""""
 set wildignore=*.obj,*.o,*~,*.pyc,*.out,*.exe
 if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif



" Text editing and searching behavior
"""""""""""""""""""""""""""""""""""""
set incsearch
set showmatch
set matchtime=2
set backspace=eol,start,indent
autocmd BufNewFile,BufRead * setlocal textwidth=0
autocmd BufNewFile,BufRead * setlocal formatoptions=tcrq

" Language specific
""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.h setlocal filetype=c
autocmd BufNewFile,BufRead *.h setlocal filetype=cpp
autocmd BufNewFile,BufRead *.hpp setlocal filetype=cpp

" term
""""""""""""""""""""""""""""""
tnoremap <Esc> <C-\><C-n>

tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
