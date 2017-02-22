let mapleader = ','

let $LD_LIBRARY_PATH=''
set rtp^=~/.vim
set rtp^=~/.vim/after

""""""""""""""""""""""""""""""
" Vundle
""""""""""""""""""""""""""""""
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin('~/.vim_runtime/bundle')

Plugin 'VundleVim/Vundle.vim'               " plugin manager
" Plugin 'majutsushi/Tagbar'                  " Displays tags in a sidebar
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
Plugin 'xolox/vim-misc'                     " auto-load vim scripts
Plugin 'scrooloose/nerdcommenter'           " intensely orgasmic commenting
Plugin 'flazz/vim-colorschemes'             " color schemes
Plugin 'morhetz/gruvbox'                    " gruvbox color scheme
Plugin 'nathanaelkane/vim-indent-guides'    " indent guides
Plugin 'godlygeek/csapprox'                 " make gvim only coloschemes work transparently in terminal vim
Plugin 'octol/vim-cpp-enhanced-highlight'   " cpp enhanced syntax highlights
Plugin 'justinmk/vim-syntax-extra'          " syntax highlight for bison and flex
Plugin 'Valloric/YouCompleteMe'             " tab completion
" Plugin 'rdnetto/YCM-Generator'              " ycm config generator
Plugin 'gregsexton/vmail'                   " mail client
Plugin 'rkitover/vimpager'                  " mita imi suge pula
" Plugin 'idanarye/vim-vebugger'              " vim debugger
" Plugin 'Shougo/vimproc.vim'                 " dependency for vebugger

call vundle#end()

filetype plugin indent on

""""""""""""""""""""""""""""""
" Cscope
""""""""""""""""""""""""""""""
if has("cscope")
        " Look for a 'cscope.out' file starting from the current directory,
        " going up to the root directory.
        let s:dirs = split(getcwd(), "/")
        while s:dirs != []
                let s:path = "/" . join(s:dirs, "/")
                if (filereadable(s:path . "/cscope.out"))
                        execute "cs add " . s:path . "/cscope.out " . s:path . " -v"
                        break
                endif
                let s:dirs = s:dirs[:-2]
        endwhile

        set csto=0	" Use cscope first, then ctags
        set cst		" Only search cscope
        set csverb	" Make cs verbose

        nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
        nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
        nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

        nmap <C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
        nmap <C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
        nmap <C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
        nmap <C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>

        " Open a quickfix window for the following queries.
        set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
endif
""""""""""""""""""""""""""""""
" YCM
""""""""""""""""""""""""""""""
let g:ycm_confirm_extra_conf = 0

nnoremap <F9> :tab split <bar> YcmCompleter GoToDeclaration<CR>
inoremap <F9> :tab split <bar> YcmCompleter GoToDeclaration<CR>
nnoremap <F8> :tab split <bar> YcmCompleter GoToDefinition<CR>
inoremap <F8> :tab split <bar> YcmCompleter GoToDefinition<CR>
nnoremap <F2> :YcmCompleter GetType<CR>
inoremap <F2> :YcmCompleter GetType<CR>

""""""""""""""""""""""""""""""
" Tagbar
""""""""""""""""""""""""""""""
nmap <F7> :TagbarToggle<CR>

""""""""""""""""""""""""""""""
" NerdTree
""""""""""""""""""""""""""""""
let NERDTreeShowHidden=1
map <F12> :NERDTreeToggle<cr>

""""""""""""""""""""""""""""""
" Vebugger
""""""""""""""""""""""""""""""
let g:vebugger_leader='\'

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
let g:airline#extensions#tagbar#enabled = 0

let g:airline#extensions#wordcount#enabled = 1

let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#show_buffers = 0

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
" Miscellaneous
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
set cindent
set shiftwidth=4
set smarttab
set tabstop=4
set softtabstop=4
set expandtab
set list
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
command! Ev tabedit $MYVIMRC
command! Sv source $MYVIMRC

command! ToggleColorColumn if &colorcolumn == "" | setlocal colorcolumn=81 | else | setlocal colorcolumn= | endif
map <A-c> :ToggleColorColumn<CR>

" Toggle folding
""""""""""""""""""""""""""""""
nnoremap <space> za

" Cursor always in the center
""""""""""""""""""""""""""""""
set so=999

" Navigation shortcuts
""""""""""""""""""""""""""""""
" treat long lines as multiple lines
map j gj
map k gk

nnoremap ; :

nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Switch between tabs
nnoremap <C-j> gT
nnoremap <C-k> gt
inoremap <C-j> <ESC>>gT
inoremap <C-k> <ESC>gt
inoremap <C-o> <ESC>
" Move tabs
nnoremap <silent> <A-i> :execute 'silent! tabmove ' . (tabpagenr() - 2)<CR>
nnoremap <silent> <A-o> :execute 'silent! tabmove ' . (tabpagenr() + 1)<CR>

" Escape
nnoremap <ESC> a

if has ('nvim')
    tnoremap <ESC> <C-\><C-n>

    tmap <A-h> <C-\><C-n><C-w>h
    tmap <A-j> <C-\><C-n><C-w>j
    tmap <A-k> <C-\><C-n><C-w>k
    tmap <A-l> <C-\><C-n><C-w>l
    tmap <A-i> <C-\><C-n>:execute "tabmove" tabpagenr() - 2 <CR>
    tmap <A-o> <C-\><C-n>:execute "tabmove" tabpagenr() + 2 <CR>

    tnoremap <C-j> <C-\><C-n>gT
    tnoremap <C-k> <C-\><C-n>gt

    autocmd BufEnter * if &buftype == "terminal" | startinsert | setlocal nonu | endif
endif

" UI
""""""""""""""""""""""""""""""
syntax on
set cursorline

syntax match Tab "    "
set background=dark
let g:gruvbox_contrast_dark = 'medium'
let g:gruvbox_bold=1
let g:gruvbox_italic=1
let g:gruvbox_underline=1
let g:gruvbox_italicize_strings=1
let g:gruvbox_inverse=0
let g:gruvbox_invert_selection=0
let g:gruvbox_invert_indent_guides=1
let g:gruvbox_invert_tabline=1


colorscheme gruvbox

set conceallevel=1 concealcursor=nvi

command! Colight set background=light
command! Codark set background=dark

command! Transp hi Normal ctermbg=None | set nocursorline
command! Solid set background=dark cursorline

set ruler
set showcmd
set number
set scrolloff=8
set report=0
set shortmess+=I
set wildmenu
set wildmode=list:longest

" ident guides
"""""""""""""""""""""""""""""""""""""""

let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermfg=3 ctermbg=None
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermfg=4 ctermbg=None



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
set smartcase
set ignorecase
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
autocmd BufNewFile,BufRead *.txx setlocal filetype=cpp

" Sudo save
""""""""""""""""""""""""""""""
command! Sw w !sudo tee % > /dev/null

" Duplicate current tab
""""""""""""""""""""""""""""""
command! -bar Dupt
      \ let s:sessionoptions = &sessionoptions |
      \ try |
      \   let &sessionoptions = 'blank,help,folds,winsize,localoptions' |
      \   let s:file = tempname() |
      \   execute 'mksession ' . s:file |
      \   tabnew |
      \   execute 'source ' . s:file |
      \ finally |
      \   silent call delete(s:file) |
      \   let &sessionoptions = s:sessionoptions |
      \   unlet! s:file s:sessionoptions |
      \ endtry

" Set clipboard to system clipboard
""""""""""""""""""""""""""""
set clipboard=unnamedplus

" Delete trailing whitespaces at write
autocmd BufWritePre * %s/\s\+$//e
