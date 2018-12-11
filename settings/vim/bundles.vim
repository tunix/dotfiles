set nocp  " no vi-compatibility
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Themes
Plugin 'dracula/vim'

" Plugins
Plugin 'tpope/vim-vinegar'
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'airblade/vim-gitgutter'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tomtom/tcomment_vim'
Plugin 'mattn/emmet-vim'
Plugin 'taglist.vim'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'danro/rename.vim'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'mileszs/ack.vim'
Plugin 'JamshedVesuna/vim-markdown-preview'

" syntax highlighting
Plugin 'elzr/vim-json'
Plugin 'groenewege/vim-less'
Plugin 'digitaltoad/vim-pug'

call vundle#end()

filetype plugin indent on
