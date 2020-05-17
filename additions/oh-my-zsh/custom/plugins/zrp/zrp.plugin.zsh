zrp() {
    plugin="$1"
    pluginReadmePath="$ZSH/plugins/$plugin/README.md"

    if [[ -f "$pluginReadmePath" ]]; then
        if type bat > /dev/null; then
            bat "$pluginReadmePath"
        else
            cat "$pluginReadmePath"
        fi
    fi
}
