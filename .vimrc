let mapleader = ','

" clear autocmd
au!

packadd termdebug

" enable true colors
execute "set t_8f=\e[38;2;%lu;%lu;%lum"
execute "set t_8b=\e[48;2;%lu;%lu;%lum"

let g:python3_host_prog = '/usr/bin/python3'
let g:python2_host_prog = '/usr/bin/python2.7'

let g:vimsyn_embed = 'l'

packadd termdebug

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

" install vim-plug if it doesn't exist
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim_runtime/bundle')

Plug 'rbong/vim-crystalline'                                    " faster airline
Plug 'majutsushi/tagbar'                                        " tagbar
Plug 'tpope/vim-fugitive'                                       " git wrapper
Plug 'easymotion/vim-easymotion'                                " easy movement
Plug 'sickill/vim-pasta'                                        " pasting in vim with indentation adjusted
Plug 'xolox/vim-misc'                                           " auto-load vim scripts
Plug 'scrooloose/nerdcommenter'                                 " intensely orgasmic commenting
Plug 'godlygeek/csapprox'                                       " make gvim only coloschemes work transparently in terminal vim
Plug 'sheerun/vim-polyglot'                                     " enhanced syntax highlights
Plug 'bfrg/vim-cpp-modern'                                      " bettert c and cpp highlights
Plug 'PotatoesMaster/i3-vim-syntax'                             " i3 syntax highlights
Plug 'xolox/vim-notes'                                          " note taking
Plug 'ncm2/float-preview.nvim'                                  " preview in floating window
Plug 'amiorin/vim-project'                                      " define projects
Plug 'scrooloose/nerdtree'                                      " file explorer
Plug 'neomake/neomake'                                          " async make
Plug 'voldikss/vim-floaterm'                                    " floating terminal
Plug 'tpope/vim-surround'                                       " surround commands foor different brackets

Plug 'mfussenegger/nvim-dap'                                    " Debug Adapter Protocol
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'theHamsta/nvim-dap-virtual-text'

Plug 'arcticicestudio/nord-vim'                                 " nord color scheme
Plug 'morhetz/gruvbox'                                          " gruvbox color scheme
Plug 'ryanoasis/vim-devicons'                                   " devicons for files

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}

call plug#end()

filetype plugin indent on

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-kotlin', 'coc-python', 'coc-lists', 'coc-highlight', 'coc-markdownlint', 'coc-vimlsp', 'coc-diagnostic']

""""""""""""""""""""""""""""""
" Local config
""""""""""""""""""""""""""""""
if !empty(glob("$HOME/.$USER.vimrc"))
    source $HOME/.$USER.vimrc
endif

""""""""""""""""""""""""""""""
" Float Term
""""""""""""""""""""""""""""""
let g:floaterm_keymap_toggle = '<A-`>'
let g:floaterm_position = 'center'
let g:floaterm_winblend = 0

""""""""""""""""""""""""""""""
" NeoMake
""""""""""""""""""""""""""""""
let g:neomake_open_list = 2

" CtrlP replacement
nnoremap <C-p> :CocList files<cr>
inoremap <C-p> <esc>:CocList files<cr>

nnoremap <C-s> :CocList symbols<cr>
inoremap <C-s> <esc>:CocList symbols<cr>

nnoremap <C-g> :CocList grep<cr>

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nmap gt <Plug>(coc-definition)
nmap Gt :tab split <bar> <Plug>(coc-definition)<cr>
nmap gr <Plug>(coc-references)

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

"augroup mygroup
    "autocmd!
    "" Setup formatexpr specified filetype(s).
    "autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    "" Update signature help on jump placeholder
    "autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    "autocmd CursorHold * silent call CocActionAsync('highlight')
"augroup end

""""""""""""""""""""""""""""""
" Git Fugitive
""""""""""""""""""""""""""""""
nnoremap <leader>gd :Gvdiffsplit<CR>

""""""""""""""""""""""""""""""
" IDE UI
""""""""""""""""""""""""""""""
let NERDTreeShowHidden=0
map <leader><leader>n :NERDTreeToggle<cr>
nnoremap <leader><leader>t :TagbarToggle<CR>
nnoremap <leader><leader>m :execute "NeomakeSh " . &makeprg<CR>

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

hi CocHighlightText guibg=238 ctermbg=238
hi link CocErrorSign GruvboxRed
hi link CocWarningSign GruvboxYellow

hi default CocErrorHighlight   cterm=underline gui=underline
hi default CocWarningHighlight cterm=underline gui=underline

hi default link CocErrorFloat CocErrorSign
hi default link CocWarningFloat CocWarningSign

command! Colight set background=light
command! Codark set background=dark

command! Transp hi Normal ctermbg=None | set nocursorline
command! Solid set background=dark cursorline

set showtabline=2
set guioptions-=e
set laststatus=2

set ruler
set showcmd
set nonumber
set report=0
set shortmess+=I
set wildmenu
set wildmode=list:longest

let g:webdevicons_enable_nerdtree = 1

""""""""""""""""""""""""""""""
" Vim-Crystalline
""""""""""""""""""""""""""""""
function! MyFiletype() abort
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! MyFileformat() abort
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! StatusLine(current, width) abort
  let l:s = ''

  if a:current
    let l:s .= crystalline#mode() . crystalline#right_mode_sep('')
  else
    let l:s .= '%#CrystallineInactive#'
  endif
  let l:s .= ' %f%h%w%m%r '
  if a:current
    let l:s .= crystalline#right_sep('', 'Fill') . ' %{FugitiveHead()}'
  endif

  let l:s .= '%='
  if a:current
    "let l:s .= '%{coc#status()}'
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    let l:s .= crystalline#left_mode_sep('')
  endif
  if a:width > 80
    let l:s .= MyFiletype() . '[%{&fenc!=#""?&fenc:&enc}][' . MyFileformat() . '] %l/%L %c%V %P '
  else
    let l:s .= ' '
  endif

  return l:s
endfunction

function! TabLabel(buf, max_width) abort
    let [l:left, l:name, l:short_name, l:right] = crystalline#default_tablabel_parts(a:buf, a:max_width)
    return l:left . l:short_name . ' ' . WebDevIconsGetFileTypeSymbol(l:name) . (l:right ==# ' ' ? '' : ' ') . l:right
endfunction

function! TabLine() abort
    return crystalline#bufferline(0, 0, 1, 1, 'TabLabel', crystalline#default_tabwidth() + 3)
endfunction

let g:crystalline_enable_sep = 1
let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_tabline_fn = 'TabLine'
let g:crystalline_theme = 'gruvbox'

""""""""""""""""""""""""""""""
" Miscellaneous
""""""""""""""""""""""""""""""

" General
""""""""""""""""""""""""""""""
set history=1000
set mouse=a
set hidden
set noshowmode
set noerrorbells
set novisualbell
set ttimeout
set ttimeoutlen=0
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
set scrolloff=999

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

    autocmd BufEnter * if &buftype == "terminal" | startinsert | setlocal nonu | setlocal so=0 | else | setlocal so=8 | endif
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

function! Wipeout()
  " list of *all* buffer numbers
  let l:buffers = range(1, bufnr('$'))

  " what tab page are we in?
  let l:currentTab = tabpagenr()
  try
    " go through all tab pages
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      " go through all windows
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " whatever buffer is in this window in this tab, remove it from
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    " if there are any buffers left, delete them
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    " go back to our original tab page
    execute 'tabnext' l:currentTab
  endtry
endfunction

" Set clipboard to system clipboard
""""""""""""""""""""""""""""
set clipboard=unnamedplus


" Delete trailing whitespaces at write
autocmd BufWritePre * %s/\s\+$//e

""""""""""""""""""""""""""""""
" DAP
""""""""""""""""""""""""""""""

"nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
"nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
"nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
"nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
"nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
"nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
"nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
"nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
"nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>

nnoremap <silent> <F6> <Cmd>lua require'dap.ext.vscode'.load_launchjs()<CR>

"lua <<EOF
"require("dapui").setup()
"require("dap").adapters.cppdbg = {
	"type = "executable",
	"command = "/usr/bin/lldb",
	"name = "lldb"
"}
"require('dap.ext.vscode').load_launchjs(nil, { cppdbg = {'c', 'cpp'} })
"require("nvim-dap-virtual-text").setup()
"EOF

