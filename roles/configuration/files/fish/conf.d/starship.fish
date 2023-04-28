if status --is-login
    if type -q starship
        starship init fish | source
    end
end
