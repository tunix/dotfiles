PROJECT_HOME="$HOME/Projects"
SANDBOX_HOME="$PROJECT_HOME/sandbox"

if [ ! -d $PROJECT_HOME ]; then
    mkdir -p $PROJECT_HOME
    mkdir -p $SANDBOX_HOME
fi

export PROJECT_HOME
export SANDBOX_HOME
