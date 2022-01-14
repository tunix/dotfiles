set gcr=   " disable cursor styling
set cul    " highlight current line
set nu     " show line number
set rnu    " show relative numbers
set tw=120 " wrap width 120
set cc=120 " show wrap column
set sb spr " split to the right & below
set si     " smartindent
set et     " use space instead of tab
set sw=4   " shiftwidth
set sts=4  " soft tab stop
set ts=4   " tab stop
set sr     " round indent to multiple of shiftwidth
set ic     " ignore case in search patterns
set scs    " override ignorecase if search pattern includes uppercase chars
set ph=10  " max no of items to show in the popup menus
set lz     " lazyredraw
set cole=2 " nicer markdown rendering
set aw     " automatically save before :next, :make etc

" Source (reload configuration)
nnoremap <silent> <F5> :source $MYVIMRC<CR>

if has('persistent_undo')
    set undofile
    set undodir=~/.cache/nvim
endif

let g:mapleader=","

" Automatically resize screens to be equally the same
autocmd VimResized * wincmd =

" Center the screen
nnoremap <space> zz

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when moving up and down
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz

" use ctrl+arrows to move between split/vsplit panels
tnoremap <C-Left> <C-\><C-n><C-w>h
tnoremap <C-Down> <C-\><C-n><C-w>j
tnoremap <C-Up> <C-\><C-n><C-w>k
tnoremap <C-Right> <C-\><C-n><C-w>l
nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l

nnoremap <S-Left> :tabprevious<cr>
nnoremap <S-Right> :tabnext<cr>

nnoremap <A-Up> :resize +2<CR> 
nnoremap <A-Down> :resize -2<CR>
nnoremap <A-Left> :vertical resize +2<CR>
nnoremap <A-Right> :vertical resize -2<CR>

noremap <C-s> :w<cr>
noremap <C-w> :hide<cr>
noremap <C-x> :bd<cr>
noremap <C-q> :qa!<cr>

" Close all but the current one
nnoremap <leader>w :only<CR>

nnoremap <C-t> :tabnew<cr>
nnoremap <leader>s :new<cr>
nnoremap <leader>v :vnew<cr>

nnoremap <Tab> :Buffers<cr>

augroup filetypedetect
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
augroup END
