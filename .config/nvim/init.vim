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

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-kotlin', 'coc-pyright', 'coc-lists', 'coc-highlight', 'coc-markdownlint', 'coc-vimlsp', 'coc-diagnostic', 'coc-lightbulb', 'coc-cmake', 'coc-lua']

""""""""""""""""""""""""""""""
" Local config
""""""""""""""""""""""""""""""
if !empty(glob("$HOME/.$USER.vimrc"))
    source $HOME/.$USER.vimrc
endif

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

nmap gt <cmd>Telescope coc definitions<cr>
nmap gt <cmd>Telescope coc definitions<cr>
nmap gr <cmd>Telescope coc references<cr>

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
nnoremap <silent> <space>a  :<C-u>Telescope coc diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>Telescope coc commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
"nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
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

xmap <leader>x <Plug>(coc-codeaction-cursor)
nmap <leader>x <Plug>(coc-codeaction-cursor)

nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

nnoremap <C-s> :Telescope coc workspace_symbols<cr>
nnoremap <C-s> :Telescope coc workspace_symbols<cr>
inoremap <C-s> <esc>:Telescope coc workspace_symbols<cr>

"augroup mygroup
    "autocmd!
    "" Setup formatexpr specified filetype(s).
    "autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    "" Update signature help on jump placeholder
    "autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    "autocmd CursorHold * silent call CocActionAsync('highlight')
"augroup end

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
autocmd BufNewFile,BufRead * setlocal textwidth=0
autocmd BufNewFile,BufRead * setlocal formatoptions=tcrqnj

" Language specific
""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.txx setlocal filetype=cpp
autocmd BufNewFile,BufRead *.ver setlocal filetype=cpp

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

function! IsWSL()
  if has("unix")
    let lines = readfile("/proc/version")
    if lines[0] =~ "Microsoft"
      return 1
    endif
  endif
  return 0
endfunction

" Set clipboard to system clipboard
""""""""""""""""""""""""""""

set clipboard=unnamedplus
if IsWSL()
    let g:clipboard = {
              \   'name': 'win32yank-wsl',
              \   'copy': {
              \      '+': 'win32yank.exe -i --crlf',
              \      '*': 'win32yank.exe -i --crlf',
              \    },
              \   'paste': {
              \      '+': 'win32yank.exe -o --lf',
              \      '*': 'win32yank.exe -o --lf',
              \   },
              \   'cache_enabled': 0,
              \ }
endif

" Delete trailing whitespaces at write
autocmd BufWritePre * %s/\s\+$//e

" Load lua config
lua require("init")
