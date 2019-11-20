let mapleader = ','

let g:python3_host_prog = '/usr/bin/python3'
let g:python2_host_prog = '/usr/bin/python2.7'

set rtp^=~/.vim
set rtp^=~/.vim/after

""""""""""""""""""""""""""""""
" vim-plug
""""""""""""""""""""""""""""""
set nocompatible
set noswapfile
set nobackup
filetype off

set rtp+=~/.vim/bundle/vim-plug

call plug#begin('~/.vim_runtime/bundle')

Plug 'vim-airline/vim-airline'                                  " status/tabline
Plug 'vim-airline/vim-airline-themes'                           " vim airline themes
Plug 'majutsushi/tagbar'                                        " tagbar
Plug 'tpope/vim-fugitive'                                       " git wrapper
Plug 'easymotion/vim-easymotion'                                " easy movement
Plug 'sickill/vim-pasta'                                        " pasting in vim with indentation adjusted
Plug 'xolox/vim-misc'                                           " auto-load vim scripts
Plug 'scrooloose/nerdcommenter'                                 " intensely orgasmic commenting
Plug 'godlygeek/csapprox'                                       " make gvim only coloschemes work transparently in terminal vim
Plug 'sheerun/vim-polyglot'                                     " enhanced syntax highlights
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'mileszs/ack.vim'                                          " search tool
Plug 'aaronbieber/vim-quicktask'                                " task management
Plug 'xolox/vim-notes'                                          " note taking
Plug 'ncm2/float-preview.nvim'                                  " preview in floating window
Plug 'amiorin/vim-project'                                      " define projects
Plug 'scrooloose/nerdtree'                                      " file explorer

Plug 'morhetz/gruvbox'                                          " gruvbox color scheme

call plug#end()

filetype plugin indent on

""""""""""""""""""""""""""""""
" UI
""""""""""""""""""""""""""""""
syntax on
set cursorline

set fillchars+=vert:│
autocmd ColorScheme * highlight VertSplit cterm=NONE ctermbg=NONE
autocmd ColorScheme * highlight CursorLine ctermbg=236

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

hi CocHighlightText guibg=239 ctermbg=239

command! Colight set background=light
command! Codark set background=dark

command! Transp hi Normal ctermbg=None | set nocursorline
command! Solid set background=dark cursorline

set ruler
set showcmd
set nonumber
set scrolloff=8
set report=0
set shortmess+=I
set wildmenu
set wildmode=list:longest

""""""""""""""""""""""""""""""
" Local config
""""""""""""""""""""""""""""""
if !empty(glob("$HOME/.$USER.vimrc"))
    source $HOME/.$USER.vimrc
endif

""""""""""""""""""""""""""""""
" coc completion
""""""""""""""""""""""""""""""
let g:coc_global_extensions = ['coc-json', 'coc-python', 'coc-highlight', 'coc-lists', 'coc-yank', 'coc-vimlsp', 'coc-tabnine', 'coc-markdownlint']

" CtrlP replacement
nnoremap <C-p> :CocList files<cr>
inoremap <C-p> <esc>:CocList files<cr>

nnoremap <C-g> :CocList grep<cr>

set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nnoremap gt <Plug>(coc-definition)
nnoremap Gt :tab split <bar> <Plug>(coc-definition)<cr>

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

xmap <leader><leader>f  <Plug>(coc-format-selected)
nmap <leader><leader>f  <Plug>(coc-format-selected)

nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

""""""""""""""""""""""""""""""
" Git Fugitive
""""""""""""""""""""""""""""""
nnoremap <leader>gd :Gvdiffsplit<CR>

""""""""""""""""""""""""""""""
" QuickTask
""""""""""""""""""""""""""""""
let g:quicktask_autosave = 1

""""""""""""""""""""""""""""""
" IDE UI
""""""""""""""""""""""""""""""
let NERDTreeShowHidden=0
map <leader><leader>n :NERDTreeToggle<cr>
nnoremap <leader><leader>t :TagbarToggle<CR>
nnoremap <leader><leader>m :make!<CR>

""""""""""""""""""""""""""""""
" TermDebug
""""""""""""""""""""""""""""""
packadd termdebug

nnoremap <F5> :Continue<CR>
nnoremap <F10> :Over<CR>
nnoremap <F11> :Step<CR>
nnoremap <F9> :Finish<CR>
nnoremap <F8> :Break<CR>

let termdebugger = "gdb-multiarch"

let g:termdebug_useFloatingHover = 1

hi debugPC term=reverse ctermbg=darkblue guibg=darkblue
hi debugBreakpoint term=reverse ctermbg=red guibg=red

""""""""""""""""""""""""""""""
" CTags
""""""""""""""""""""""""""""""
nnoremap g] g<C-]>
nnoremap G] :tab split<CR>:exec("tjump ".expand("<cword>"))<CR>

""""""""""""""""""""""""""""""
" Easy Motion
""""""""""""""""""""""""""""""
map <Leader> <Plug>(easymotion-prefix)
map s <Plug>(easymotion-s2)

"map / <Plug>(easymotion-sn)
"omap / <Plug>(easymotion-tn)

"map n <Plug>(easymotion-next)
"map N <Plug>(easymotion-prev)

map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_keys = 'asdfjklghvncmxturiewo'
let g:EasyMotion_smartcase = 1

""""""""""""""""""""""""""""""
" ACK
""""""""""""""""""""""""""""""
if executable('rg')
  let g:ackprg = 'rg --vimgrep --ignore-file ~/.ignore'
endif
let g:ack_use_dispatch = 0


""""""""""""""""""""""""""""""
" Vim Latex Live Previewer
""""""""""""""""""""""""""""""

" Run a shell command in background
function! RunInBackground(cmd)

python << EEOOFF

try:
    import vim
    import tempfile
    import subprocess
    import os

    subprocess.Popen(
            vim.eval('a:cmd'),
            shell = True,
            universal_newlines = True,
            stdout=open(os.devnull, 'w'), stderr=subprocess.STDOUT)

except:
    pass
EEOOFF
endfunction

autocmd CursorHold,CursorHoldI,BufWritePost *.tex
            \ let pth = substitute(expand('%:p:h'), 'src.*', '', '') |
            \ exec 'lcd ' . pth |
            \ call RunInBackground('make') |
            \ lcd -

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

let g:airline#extensions#syntastic#enabled = 0
let g:airline#extensions#tagbar#enabled = 0

let g:airline#extensions#wordcount#enabled = 1

let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#show_buffers = 0

let g:airline#extensions#tabline#show_splits = 0

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
set mouse=a
set nohidden
set noshowmode
set noerrorbells
set novisualbell
set timeoutlen=500
set updatetime=300
set splitbelow
set splitright
set exrc
set secure
"set ttyfast
set lazyredraw
let loaded_matchparen = 1

" Indent and tab
""""""""""""""""""""""""""""""
set foldcolumn=0
set foldlevelstart=99
set foldmethod=indent
set cindent
set shiftwidth=4
set smarttab
set tabstop=4
set softtabstop=4
set expandtab
set list
set listchars=tab:»\ ,
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
"nnoremap <space> za

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
"inoremap <C-j> <ESC>>gT
"inoremap <C-k> <ESC>gt
"inoremap <C-o> <ESC>

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
setglobal modeline
set smartcase
set ignorecase
set incsearch
set icm=nosplit
set showmatch
set matchtime=2
set backspace=eol,start,indent
autocmd BufNewFile,BufRead * setlocal textwidth=0
autocmd BufNewFile,BufRead * setlocal formatoptions=tcrqnj


" Language specific
""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.h setlocal filetype=c
autocmd BufNewFile,BufRead *.h setlocal filetype=cpp
autocmd BufNewFile,BufRead *.hpp setlocal filetype=cpp
autocmd BufNewFile,BufRead *.txx setlocal filetype=cpp
autocmd BufNewFile,BufRead *.ver setlocal filetype=cpp

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
