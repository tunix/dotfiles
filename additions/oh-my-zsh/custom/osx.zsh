# Assuming that all below packages are installed via brew

PLATFORM="$(uname)"

if [[ $PLATFORM != "Darwin" ]]; then
    return
fi

# vim aliases
alias ctags="`brew --prefix`/bin/ctags"

setjdk() {
    export JAVA_HOME=$(/usr/libexec/java_home -v $1)
}
