if status --is-login
    if not test -f $HOME/.config/fish/fish_plugins
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source \
            && fisher install jorgebucaran/fisher

        if test -f $HOME/.config/fish/fish_plugins_dotfiles
            cat $HOME/.config/fish/fish_plugins_dotfiles >> $HOME/.config/fish/fish_plugins

            fisher update
        end
    end
end
