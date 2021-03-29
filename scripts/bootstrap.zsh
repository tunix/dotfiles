#!/bin/zsh

DOTFILES_ROOT="$(pwd)"

# deleting existing files first
rm -rf $HOME/.local/bin/genpwd &> /dev/null
rm -rf $HOME/.zshrc &> /dev/null
rm -rf $HOME/.oh-my-zsh-custom &> /dev/null
rm -rf $HOME/.gitconfig &> /dev/null
rm -rf $HOME/.config/nvim &> /dev/null
rm -rf $HOME/.config/alacritty &> /dev/null
rm -rf $HOME/.tmux.conf &> /dev/null
rm -rf $HOME/.editorconfig &> /dev/null
rm -rf $HOME/.ssh &> /dev/null

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh

# installing scripts
ln -sf $DOTFILES_ROOT/scripts/generate_password.py $HOME/.local/bin/genpwd

# zsh
ln -sf $DOTFILES_ROOT/settings/zshrc $HOME/.zshrc
ln -sf $DOTFILES_ROOT/additions/oh-my-zsh/custom $HOME/.oh-my-zsh-custom

# git
ln -sf $DOTFILES_ROOT/settings/gitconfig $HOME/.gitconfig

# ssh
ln -sf $DOTFILES_ROOT/settings/ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub

# nvim
ln -sf $DOTFILES_ROOT/settings/nvim $HOME/.config/nvim

# others
ln -sf $DOTFILES_ROOT/settings/tmux.conf $HOME/.tmux.conf
ln -sf $DOTFILES_ROOT/settings/editorconfig $HOME/.editorconfig

# alacritty
mkdir -p $HOME/.config/alacritty \
    && ln -sf $DOTFILES_ROOT/settings/alacritty.yml $HOME/.config/alacritty/alacritty.yml

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
fi

# run zsh configuration before below command
source $HOME/.zshrc

# merge ssh configs
cat $HOME/.ssh/config_* > $HOME/.ssh/config
cat $HOME/.ssh/*.pub > $HOME/.ssh/authorized_keys

# vim:set ft=zsh et sw=4:
