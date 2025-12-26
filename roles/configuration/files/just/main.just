import? x'$HOME/.config/just/midas/main.just'

default:
    just --list

[linux]
ghostty-appimage:
    dconf write /org/gnome/shell/favorite-apps "['com.brave.Browser.desktop', 'org.gnome.Nautilus.desktop', 'ghostty.desktop', 'com.spotify.Client.desktop', 'org.gnome.Software.desktop', 'org.gnome.Settings.desktop', 'org.telegram.desktop.desktop', 'com.slack.Slack.desktop', 'com.discordapp.Discord.desktop', 'md.obsidian.Obsidian.desktop']"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'/var/home/tunix/AppImages/ghostty.appimage'"

[macos]
update-brew-casks:
    #/bin/bash

    for pkg in $(brew list --casks); do
    brew upgrade --cask $pkg
    done

alias ubc := update-brew-casks
