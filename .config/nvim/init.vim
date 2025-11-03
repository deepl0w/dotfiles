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

" edit and source configs
""""""""""""""""""""""""""""""
command! Ev tabedit $MYVIMRC | vsplit $HOME/.config/nvim/lua/init.lua
command! Sv source $MYVIMRC | luafile $HOME/.config/nvim/lua/init.lua

" Load lua config
lua require("init")
