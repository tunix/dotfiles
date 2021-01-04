let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
let g:NERDTreeWinSize = 60

" Toggle
nnoremap <silent> <C-n> :NERDTreeToggle<CR>

" https://github.com/preservim/nerdtree/wiki/F.A.Q.#how-can-i-make-sure-vim-does-not-open-files-and-other-buffers-on-nerdtree-window
" If more than one window and previous buffer was NERDTree, go back to it.
autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif

let g:plug_window = 'noautocmd vertical topleft new'
