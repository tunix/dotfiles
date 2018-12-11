NPM_HOME="$HOME/.npm"
NPMRC="$HOME/.npmrc"

if [[ ! -f $NPMRC ]]; then
    mkdir -p $NPM_HOME
    echo prefix=$NPM_HOME > $NPMRC
fi

export PATH="$PATH:$NPM_HOME/bin"
