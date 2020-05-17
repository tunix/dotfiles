#!/bin/bash

DOTFILES_ROOT="$(pwd)"

# deleting existing files first
rm -rf $HOME/.local/bin/genpwd &> /dev/null
rm -rf $HOME/.zshrc &> /dev/null
rm -rf $HOME/.oh-my-zsh-custom &> /dev/null
rm -rf $HOME/.gitconfig &> /dev/null
rm -rf $HOME/.vim* &> /dev/null
rm -rf $HOME/.config/nvim &> /dev/null
rm -rf $HOME/.tmux.conf &> /dev/null
rm -rf $HOME/.editorconfig &> /dev/null
rm -rf $HOME/.ssh &> /dev/null

# resetting changes to these files
git checkout .

# installing scripts
ln -sf $DOTFILES_ROOT/scripts/generate_password.py $HOME/.local/bin/genpwd

# zsh
ln -sf $DOTFILES_ROOT/settings/zshrc $HOME/.zshrc
ln -sf $DOTFILES_ROOT/additions/oh-my-zsh/custom $HOME/.oh-my-zsh-custom

# git
ln -sf $DOTFILES_ROOT/settings/gitconfig $HOME/.gitconfig

# vim
ln -sf $DOTFILES_ROOT/settings/vim $HOME/.vim
ln -sf $DOTFILES_ROOT/settings/vimrc $HOME/.vimrc

# nvim
mkdir -p $HOME/.config
ln -sf $DOTFILES_ROOT/settings/nvim $HOME/.config/nvim

# others
ln -sf $DOTFILES_ROOT/settings/tmux.conf $HOME/.tmux.conf
ln -sf $DOTFILES_ROOT/settings/editorconfig $HOME/.editorconfig

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
fi

# merge ssh configs
cat $HOME/.ssh/config_* > $HOME/.ssh/config
