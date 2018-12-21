# in_array "foo" "${array[@]}"
in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}

lineCount() {
    if [ -z $1 ]; then
        return 1
    fi

    cat "$1" | wc -l
}

myip() {
    IP=`http -b checkip.amazonaws.com|tr -d '\n'`

    echo $IP
}

gi() {
    curl -L -s https://www.gitignore.io/api/$@
}

weather() {
    curl http://wttr\.in/$1\?m
}
