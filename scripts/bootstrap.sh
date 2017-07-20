#!/bin/zsh

DOTFILES_ROOT="$(pwd)"
PLATFORM="$(uname)"
SERVER_APPS_PATH="/srv/apps"
SERVER_VENV_PATH="/srv/virtualenvs"
OSX_TMUX_CHANGES='
# Use vim keybindings in copy mode
setw -g mode-keys vi

# Setup "v" to begin selection as in Vim
bind-key -Tcopy-mode-vi "v" send -X begin-selection
bind-key -Tcopy-mode-vi "y" send -X copy-selection
'

# deleting existing files first
rm -rf $HOME/.bin/arch-packages-news.py &> /dev/null
rm -rf $HOME/.bin/genpwd &> /dev/null
rm -rf $HOME/.bin/imgcat &> /dev/null
rm -rf $HOME/.zshrc &> /dev/null
rm -rf $HOME/.gitconfig &> /dev/null
rm -rf $HOME/.oh-my-zsh &> /dev/null
rm -rf $HOME/.vim* &> /dev/null
rm -rf $HOME/.gvimrc &> /dev/null
rm -rf $HOME/.isort.cfg &> /dev/null
rm -rf $HOME/.pythonrc &> /dev/null
rm -rf $HOME/.tmux.conf &> /dev/null
rm -rf $HOME/.hgrc &> /dev/null

# only delete .ssh/authorized_keys if not in vagrant machine
if [ ! -d /vagrant ]; then
    rm -rf $HOME/.ssh/authorized_keys &> /dev/null
fi

# resetting changes to these files
git checkout .

# initializing submodules
git submodule init
git submodule update

# installing scripts
mkdir -p $HOME/.bin
ln -sf $DOTFILES_ROOT/scripts/arch-packages-news.py $HOME/.bin/arch-packages-news.py
ln -sf $DOTFILES_ROOT/scripts/generate_password.py $HOME/.bin/genpwd
ln -sf $DOTFILES_ROOT/scripts/imgcat $HOME/.bin/imgcat

# zsh
ln -sf $DOTFILES_ROOT/settings/zshrc $HOME/.zshrc

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

# oh-my-zsh
ln -sf $DOTFILES_ROOT/settings/oh-my-zsh $HOME/.oh-my-zsh

# vim
ln -sf $DOTFILES_ROOT/settings/vim $HOME/.vim
ln -sf $DOTFILES_ROOT/settings/vimrc $HOME/.vimrc
ln -sf $DOTFILES_ROOT/settings/gvimrc $HOME/.gvimrc

# others
ln -sf $DOTFILES_ROOT/settings/isort.cfg $HOME/.isort.cfg
ln -sf $DOTFILES_ROOT/settings/pythonrc $HOME/.pythonrc
ln -sf $DOTFILES_ROOT/settings/tmux.conf $HOME/.tmux.conf
ln -sf $DOTFILES_ROOT/settings/editorconfig $HOME/.editorconfig

# OSX changes
if [[ $PLATFORM == "Darwin" ]]; then
    # tmux
    echo $OSX_TMUX_CHANGES >> $HOME/.tmux.conf

    # vim ctags
    sed -i -e 's|/usr/bin/ctags|/usr/local/bin/ctags|g' $DOTFILES_ROOT/settings/vimrc
fi

# enabling settings
source $HOME/.zshrc &> /dev/null

# server path definition changes
if [[ $PLATFORM != "Darwin" && ! -d /vagrant ]]; then
    sed -i -e 's|$HOME/projects|/srv/apps|g' $DOTFILES_ROOT/settings/zshrc
    sed -i -e 's|$HOME/.virtualenvs|/srv/virtualenvs|g' $DOTFILES_ROOT/settings/zshrc
fi

# merge ssh configs
cat $HOME/.ssh/config_* > $HOME/.ssh/config
