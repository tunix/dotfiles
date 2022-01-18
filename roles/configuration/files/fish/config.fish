if status is-interactive

    #
    # Aliases
    #

    
    #
    # Abbreviations
    #

        
    
    # Make rm a little safer (have it prompt once when deleting
    # more than three files or when deleting recursively).
    abbr --add --global rm "rm -I"

    # A nicer ls that also shows the git status of files
    abbr --add --global l "exa -lh --group-directories-first --all"

    # A nicer ls that also shows the git status of files
    # (but not hidden files)
    abbr --add --global ll "exa -lh --group-directories-first"

    # Same nicer ls but in tree view.
    abbr --add --global lt "exa -lh --group-directories-first --all --tree"

    # lc = line count
    abbr --add --global lc "wc -l"

    # Find out what’s running on port X
    abbr --add --global port "lsof -i"

end
