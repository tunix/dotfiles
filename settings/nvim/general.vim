set gcr=         " disable cursor styling
set cul          " highlight current line
set nu           " show line number
set rnu          " show relative numbers
set tw=120       " wrap width 120
set cc=120       " show wrap column
set sb spr       " split to the right & below
set si           " smartindent
set et           " use space instead of tab
set sw=4         " shiftwidth
set sts=4        " soft tab stop
set ts=4         " tab stop
set sr           " round indent to multiple of shiftwidth
set ic           " ignore case in search patterns
set scs          " override ignorecase if search pattern includes uppercase chars
set ph           " max no of items to show in the popup menus
set lz           " lazyredraw

if has('persistent_undo')
    set undofile
    set undodir=~/.cache/nvim
endif

let g:mapleader=","

" use alt+hjkl to move between split/vsplit panels
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

nnoremap <A-Up> :resize +2<CR> 
nnoremap <A-Down> :resize -2<CR>
nnoremap <A-Left> :vertical resize +2<CR>
nnoremap <A-Right> :vertical resize -2<CR>

noremap <C-s> :w<cr>
noremap <C-w> :hide<cr>
noremap <C-x> :bd<cr>
noremap <C-q> :qa!<cr>

nnoremap <leader>n :tabnew<cr>
nnoremap <Tab> :Buffers<cr>
