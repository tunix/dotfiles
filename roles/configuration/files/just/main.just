import? x'$HOME/.config/just/midas/main.just'

default:
    just --list

update-skel:
    #!/usr/bin/bash
    rsync -avz /etc/skel/ $HOME

install-lunarvim:
    #!/usr/bin/bash
    LV_BRANCH='release-1.4/neovim-0.9' \
        bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh) \
        -y --install-dependencies

ghostty-appimage:
    dconf write /org/gnome/shell/favorite-apps "['com.brave.Browser.desktop', 'org.gnome.Nautilus.desktop', 'ghostty.desktop', 'com.spotify.Client.desktop', 'org.gnome.Software.de
sktop', 'org.gnome.Settings.desktop', 'org.telegram.desktop.desktop', 'com.slack.Slack.desktop', 'com.discordapp.Discord.desktop', 'md.obsidian.Obsidian.desktop']"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'/var/home/tunix/AppImages/ghostty.appimage'"
