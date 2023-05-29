if status --is-login
    # disable greeting
    set -U fish_greeting

    # add ~/.local/bin to PATH
    fish_add_path ~/.local/bin {{ shell.path }}

    # define XDG_CONFIG_HOME
    set -Ux XDG_CONFIG_HOME $HOME/.config
end
