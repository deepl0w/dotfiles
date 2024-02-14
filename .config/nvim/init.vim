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

""""""""""""""""""""""""""""""
" Local config
""""""""""""""""""""""""""""""
if !empty(glob("$HOME/.$USER.vimrc"))
    source $HOME/.$USER.vimrc
endif

 nnoremap <C-g> :CocList grep<cr>

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

" edit and source configs
""""""""""""""""""""""""""""""
command! Ev tabedit $MYVIMRC | vsplit $HOME/.config/nvim/lua/init.lua
command! Sv source $MYVIMRC | luafile $HOME/.config/nvim/lua/init.lua

" Load lua config
lua require("init")
