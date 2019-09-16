let mapleader = ','

let g:python3_host_prog = '/usr/bin/python3'
let g:python2_host_prog = '/usr/bin/python2.7'

""""""""""""""""""""""""""""""
" ALE
""""""""""""""""""""""""""""""
let g:ale_lint_on_enter=0
let g:ale_lint_on_insert_leave=1
let g:ale_lint_on_save = 1
let g:ale_completion_enabled=0
let g:ale_set_balloons=0

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
set rtp+=~/git/debubber

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py --clang-completer
  endif
endfunction

call plug#begin('~/.vim_runtime/bundle')

Plug 'vim-airline/vim-airline'                                  " status/tabline
Plug 'vim-airline/vim-airline-themes'                           " vim airline themes
Plug 'majutsushi/tagbar'                                        " tagbar
Plug 'tpope/vim-fugitive'                                       " git wrapper
Plug 'tpope/vim-surround'                                       " mappings to easily delete, change and add such surroundings in pairs
Plug 'kien/ctrlp.vim'                                           " Full path fuzzy file, buffer, mru, tag finder
Plug 'easymotion/vim-easymotion'                                " easy movement
Plug 'sickill/vim-pasta'                                        " pasting in vim with indentation adjusted
Plug 'xolox/vim-misc'                                           " auto-load vim scripts
Plug 'scrooloose/nerdcommenter'                                 " intensely orgasmic commenting
Plug 'morhetz/gruvbox'                                          " gruvbox color scheme
Plug 'godlygeek/csapprox'                                       " make gvim only coloschemes work transparently in terminal vim
Plug 'octol/vim-cpp-enhanced-highlight'                         " cpp enhanced syntax highlights
Plug 'Valloric/YouCompleteMe', {'do': function('BuildYCM')}     " tab completion
Plug 'sakhnik/nvim-gdb/', { 'do': ':!./install.sh', 'branch': 'legacy' }
Plug 'SirVer/ultisnips'                                         " vim snippet engine
Plug 'honza/vim-snippets'                                       " vim snippets
Plug 'mileszs/ack.vim'                                          " search tool
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}
Plug 'juneedahamed/svnj.vim'                                    " SVN integration
Plug 'aaronbieber/vim-quicktask'                                " task management
Plug 'juneedahamed/vc.vim'                                      " SVN integration
Plug 'lyuts/vim-rtags'                                          " rtags integration
>>>>>>> Stashed changes

call plug#end()

filetype plugin indent on

""""""""""""""""""""""""""""""
" QuickTask
""""""""""""""""""""""""""""""
let g:quicktask_autosave = 1

""""""""""""""""""""""""""""""
" Tagbar
""""""""""""""""""""""""""""""
nnoremap <F12> :TagbarToggle<CR>

""""""""""""""""""""""""""""""
" NVIM GDB
""""""""""""""""""""""""""""""
let g:nvimgdb_config_override = {
  \ 'key_frameup': '<f2>',
  \ 'key_framedown': '<f3>',
  \ }

""""""""""""""""""""""""""""""
" neobugger
""""""""""""""""""""""""""""""

let g:gdb_keymap_continue = '<f5>'
let g:gdb_keymap_next = '<f10>'
let g:gdb_keymap_step = '<f11>'
" Usually, F23 is just Shift+F11
let g:gdb_keymap_finish = '<f23>'
let g:gdb_keymap_toggle_break = '<f9>'
" Usually, F33 is just Ctrl+F9
let g:gdb_keymap_toggle_break_all = '<f33>'
let g:gdb_keymap_frame_up = '<f2>'
let g:gdb_keymap_frame_down = '<f3>'
" Usually, F21 is just Shift+F9
let g:gdb_keymap_clear_break = '<f21>'
" Usually, F17 is just Shift+F5
let g:gdb_keymap_debug_stop = '<f4>'

""""""""""""""""""""""""""""""
" CTags
""""""""""""""""""""""""""""""
nnoremap <leader>. :CtrlPTag<cr>
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
" YCM
""""""""""""""""""""""""""""""
let g:ycm_confirm_extra_conf = 0
let g:ycm_goto_buffer_command = 'new-or-existing-tab'

set completeopt-=preview

nnoremap <leader>,d :YcmDiags<CR>
nnoremap gt :YcmCompleter GoTo<CR>
nnoremap Gt :tab split <bar> YcmCompleter GoTo<CR>
"nnoremap gt :YcmCompleter GoToDeclaration<CR>
nnoremap gd :YcmCompleter GoToDefinition<CR>
nnoremap Gt :tab split <bar> YcmCompleter GoToDefinition<CR>

let g:ycm_server_keep_logfiles = 1
let g:ycm_warning_symbol = '>'
let g:ycm_error_symbol = '>>'
let g:ycm_server_use_vim_stdout = 1
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_collect_identifiers_from_tags_files = 1

""""""""""""""""""""""""""""""
" Vebugger
""""""""""""""""""""""""""""""
let g:vebugger_leader='<Leader>d'

""""""""""""""""""""""""""""""
" Submodes
""""""""""""""""""""""""""""""
fun! ToggleDebugMode()
    if !exists('b:debug_mode')
        nnoremap c :VBGcontinue<CR>
        nnoremap n :VBGstepOver<CR>
        nnoremap s :VBGstepIn<CR>
        nnoremap o :VBGstepOut<CR>
        nnoremap b :VBGtoggleBreakpointThisLine<CR>
        nnoremap B :VBGclearBreakpoints<CR>
        nnoremap e :VBGevalWordUnderCursor<CR>
        nnoremap E :VBGeval<CR>
        nnoremap x :VBGexecute<CR>

        let b:debug_mode=1
    else
        unmap c
        unmap n
        unmap s
        unmap o
        unmap b
        unmap B
        unmap e
        unmap E
        unmap x

        unlet b:debug_mode
    endif

    return ""
endfun

nnoremap <c-a-d> :call ToggleDebugMode()<CR>

""""""""""""""""""""""""""""""
" Snippets
""""""""""""""""""""""""""""""

let g:UltiSnipsExpandTrigger="<c-o>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

let g:UltiSnipsEditSplit="vertical"

""""""""""""""""""""""""""""""
" Tagbar
""""""""""""""""""""""""""""""
nmap <F7> :TagbarToggle<CR>

""""""""""""""""""""""""""""""
" NerdTree
""""""""""""""""""""""""""""""
"let NERDTreeShowHidden=1
"map <F12> :NERDTreeTabsToggle<cr>

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
"Syntastic
""""""""""""""""""""""""""""""
let g:ale_sign_error = '†'
let g:ale_sign_warning = '★'
let g:ale_linters = { 'c': ['cppcheck'], 'cpp': ['cppcheck']}

let g:ale_c_build_dir_names= ['build', 'bin', 'platform/linux/build']
let g:ale_c_parse_compile_commands=1

let g:ale_c_clang_executable='clang'

let g:ale_cpp_clang_executable='clang'

let g:airline#extensions#ale#enabled = 1

let g:syntastic_c_compiler_options = '-std=c99 -Wall -Wextra'
let g:syntastic_cpp_compiler_options = '-std=c++14 -Wall -Wextra'
let g:loaded_syntastic_c_gcc_checker = 'gcc'

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

" UI
""""""""""""""""""""""""""""""
syntax on
set cursorline

set fillchars+=vert:│
autocmd ColorScheme * highlight VertSplit cterm=NONE ctermbg=NONE
"autocmd ColorScheme * highlight CursorLine ctermbg=236

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
