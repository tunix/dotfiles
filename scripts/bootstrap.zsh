#!/bin/zsh

source "$(dirname $0)"/common.sh

DOTFILES_ROOT="$(getDotFilesRoot)"

# deleting existing files first
delete "$HOME/.local/bin/genpwd"
delete "$HOME/.zshrc"
delete "$HOME/.oh-my-zsh-custom"
delete "$HOME/.gitconfig"
delete "$HOME/.ssh"
delete "$HOME/.config/nvim"
delete "$HOME/.tmux*"
delete "$HOME/.editorconfig"
delete "$HOME/.config/alacritty"
delete "$HOME/.dircolors"

seperator

mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh

# installing scripts
install $DOTFILES_ROOT/scripts/generate_password.py $HOME/.local/bin/genpwd

# zsh
install $DOTFILES_ROOT/settings/zshrc $HOME/.zshrc
install $DOTFILES_ROOT/additions/oh-my-zsh/custom $HOME/.oh-my-zsh-custom

# git
install $DOTFILES_ROOT/settings/gitconfig $HOME/.gitconfig

# ssh
install $DOTFILES_ROOT/settings/ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub

# nvim
install $DOTFILES_ROOT/settings/nvim $HOME/.config/nvim

# others
install $DOTFILES_ROOT/settings/tmux.conf $HOME/.tmux.conf
install $DOTFILES_ROOT/settings/editorconfig $HOME/.editorconfig

# alacritty
mkdir -p $HOME/.config/alacritty \
    && install $DOTFILES_ROOT/settings/alacritty.yml $HOME/.config/alacritty/alacritty.yml

seperator

clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
clone https://github.com/arcticicestudio/nord-dircolors.git /tmp/nord-dircolors \
    && cp /tmp/nord-dircolors/src/dir_colors $HOME/.dir_colors

seperator

# run zsh configuration before below command
source $HOME/.zshrc

# merge ssh configs
echo "Harnessing SSH configuration..."

cat $HOME/.ssh/config_* > $HOME/.ssh/config
cat $HOME/.ssh/*.pub > $HOME/.ssh/authorized_keys

# vim:set ft=zsh et sw=4:
