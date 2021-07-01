# in_array "foo" "${array[@]}"
in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}

myip() {
    IP=`http -b checkip.amazonaws.com|tr -d '\n'`

    echo $IP
}

weather() {
    curl http://wttr\.in/$1\?m
}

git_slow() {
    # disables ZSH's git prompt functions which cause issue for big projects

    git config oh-my-zsh.hide-info 1   # git_prompt_info
    git config oh-my-zsh.hide-status 1 # git_prompt_status
    git config oh-my-zsh.hide-dirty 1  # parse_git_dirty
}
