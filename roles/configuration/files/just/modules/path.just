# re-applies the canonical PATH order from init.fish; universal variable
# changes propagate live to running fish sessions
@path-fix:
    fish -l -c 'source $HOME/.config/fish/conf.d/init.fish; echo $PATH'
