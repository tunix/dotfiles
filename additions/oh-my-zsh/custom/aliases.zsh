alias vi="nvim"
alias vim="nvim"
alias ls="ls --group-directories-first --color"
alias ll="ls -l --group-directories-first --color"
alias open="xdg-open"
alias df="df -x squashfs"

# prune local tags & fetch remote tags
gpt() {
    git tag -l | xargs git tag -d && git fetch -t
}

bat() {
    batcat "$@"
}
