#!/bin/zsh

DOTFILES_ROOT="$(pwd)"
PLATFORM="$(uname)"
OSX_TMUX_CHANGES='
# Use vim keybindings in copy mode
setw -g mode-keys vi

# Setup "v" to begin selection as in Vim
bind-key -Tcopy-mode-vi "v" send -X begin-selection
bind-key -Tcopy-mode-vi "y" send -X copy-selection
'

# deleting existing files first
rm -rf $HOME/.bin/genpwd &> /dev/null
rm -rf $HOME/.zshrc &> /dev/null
rm -rf $HOME/.oh-my-zsh-custom &> /dev/null
rm -rf $HOME/.gitconfig &> /dev/null
rm -rf $HOME/.vim* &> /dev/null
rm -rf $HOME/.tmux.conf &> /dev/null
rm -rf $HOME/.hgrc &> /dev/null
rm -rf $HOME/.config/nvim &> /dev/null

# only delete .ssh/authorized_keys if not in vagrant machine
if [ ! -d /vagrant ]; then
    rm -rf $HOME/.ssh/authorized_keys &> /dev/null
fi

# resetting changes to these files
git checkout .

# installing scripts
mkdir -p $HOME/.bin
ln -sf $DOTFILES_ROOT/scripts/generate_password.py $HOME/.bin/genpwd

# zsh
ln -sf $DOTFILES_ROOT/settings/zshrc $HOME/.zshrc
ln -sf $DOTFILES_ROOT/additions/oh-my-zsh/custom $HOME/.oh-my-zsh-custom

# only install .ssh/authorized_keys if not in vagrant machine
if [ ! -d /vagrant ]; then
    ln -sf $DOTFILES_ROOT/settings/ssh/authorized_keys $HOME/.ssh/authorized_keys
    ln -sf $DOTFILES_ROOT/settings/ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub
    ln -sf $DOTFILES_ROOT/settings/ssh/config_apilous $HOME/.ssh/config_apilous
    ln -sf $DOTFILES_ROOT/settings/ssh/config_home $HOME/.ssh/config_home
fi

# git
ln -sf $DOTFILES_ROOT/settings/gitconfig $HOME/.gitconfig

# mercurial
ln -sf $DOTFILES_ROOT/settings/hgrc $HOME/.hgrc

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

# OSX changes
if [[ $PLATFORM == "Darwin" ]]; then
    # tmux
    echo $OSX_TMUX_CHANGES >> $HOME/.tmux.conf

    # vim ctags
    sed -i -e 's|/usr/bin/ctags|/usr/local/bin/ctags|g' $DOTFILES_ROOT/settings/vimrc
fi

# enabling settings
source $HOME/.zshrc &> /dev/null

# merge ssh configs
cat $HOME/.ssh/config_* > $HOME/.ssh/config
