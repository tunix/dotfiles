#!/bin/zsh

DOTFILES_ROOT=$(pwd)

# initializing submodules
git submodule init
git submodule update

# installing scripts
mkdir -p $HOME/.bin
ln -sf $DOTFILES_ROOT/scripts/arch-packages-news.py $HOME/.bin/arch-packages-news.py
ln -sf $DOTFILES_ROOT/scripts/generate-password.py $HOME/.bin/genpwd

# zsh
ln -sf $DOTFILES_ROOT/settings/zshrc $HOME/.zshrc

# ssh
ln -sf $DOTFILES_ROOT/settings/ssh/authorized_keys $HOME/.ssh/authorized_keys

# git
mkdir -p $HOME/.git
ln -sf $DOTFILES_ROOT/settings/gitconfig $HOME/.git/gitconfig

# oh-my-zsh
ln -sf $DOTFILES_ROOT/settings/oh-my-zsh $HOME/.oh-my-zsh

# vim
ln -sf $DOTFILES_ROOT/settings/vim $HOME/.vim
ln -sf $DOTFILES_ROOT/settings/vimrc $HOME/.vimrc

# others
ln -sf $DOTFILES_ROOT/settings/isort.cfg $HOME/.isort.cfg
ln -sf $DOTFILES_ROOT/settings/pythonrc $HOME/.pythonrc
ln -sf $DOTFILES_ROOT/settings/tmux.conf $HOME/.tmux.conf

# environment related changes
# TODO: server .zshrc changes
# TODO: tmux.conf linux changes

# enabling settings
source $HOME/.zshrc &> /dev/null

echo "Environment successfully created!"
