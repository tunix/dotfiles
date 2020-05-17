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
