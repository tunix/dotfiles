if status is-interactive

    #
    # Aliases
    #

    alias bat "batcat"

    #
    # Abbreviations
    #

    # Copy and paste to the clipboard by piping to these commands.
    # (Inspired by the default behaviour in macOS.)
    abbr --add --global pbcopy "xsel --clipboard --input"
    abbr --add --global pbpaste "xsel --clipboard --output"

    # Open files in their associated apps from Terminal.
    abbr --add --global open "xdg-open &>/dev/null"

    # Make rm a little safer (have it prompt once when deleting
    # more than three files or when deleting recursively).
    abbr --add --global rm "rm -I"

    # A nicer ls that also shows the git status of files
    abbr --add --global l "exa -lh --all --group-directories-first"

    # A nicer ls that also shows the git status of files
    # (but not hidden files)
    abbr --add --global ll "exa -lh --group-directories-first"

    # Same nicer ls but in tree view.
    abbr --add --global lt "exa -lh --all --tree --group-directories-first"

    # lc = line count
    abbr --add --global lc "wc -l"

    # Find out what’s running on port X
    abbr --add --global port "lsof -i"

end
