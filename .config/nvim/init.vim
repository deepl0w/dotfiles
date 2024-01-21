let mapleader = ','

" clear autocmd
au!

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

Plug 'xolox/vim-misc'                                           " auto-load vim scripts
Plug 'scrooloose/nerdcommenter'                                 " intensely orgasmic commenting
Plug 'sickill/vim-pasta'                                        " pasting in vim with indentation adjusted
Plug 'PotatoesMaster/i3-vim-syntax'                             " i3 syntax highlights
Plug 'xolox/vim-notes'                                          " note taking
Plug 'ncm2/float-preview.nvim'                                  " preview in floating window
Plug 'voldikss/vim-floaterm'                                    " floating terminal

Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-kotlin', 'coc-pyright', 'coc-lists', 'coc-highlight', 'coc-markdownlint', 'coc-vimlsp', 'coc-diagnostic', 'coc-lightbulb', 'coc-cmake', 'coc-sumneko-lua']

"""""""""""""""""""""""""""""
" Float Term
""""""""""""""""""""""""""""""
let g:floaterm_keymap_toggle = '<leader><leader>t'
let g:floaterm_position = 'center'
let g:floaterm_winblend = 0

"nnoremap <C-g> :CocList grep<cr>

" Use tab for trigger completion with characters ahead and navigate.
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

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

""""""""""""""""""""""""""""""
" Vim Latex Live Previewer
""""""""""""""""""""""""""""""

" Run a shell command in background
function! RunInBackground(cmd)
    :silent ! a:cmd
endfunction

autocmd CursorHold,CursorHoldI,BufWritePost *.tex
            \ let pth = substitute(expand('%:p:h'), 'src.*', '', '') |
            \ exec 'lcd ' . pth |
            \ call RunInBackground('make') |
            \ lcd -

" edit and source configs
""""""""""""""""""""""""""""""
command! Ev tabedit $MYVIMRC | vsplit $HOME/.config/nvim/lua/init.lua
command! Sv source $MYVIMRC | luafile $HOME/.config/nvim/lua/init.lua

" ignore compiled files and executables
"""""""""""""""""""""""""""""""""""""""
set wildignore=*.obj,*.o,*~,*.pyc,*.out,*.exe
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

" Load lua config
lua require("init")
