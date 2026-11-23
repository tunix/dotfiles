#!/usr/bin/env bash

ZELLIJ_LIGHT_THEME="catppuccin-latte"
ZELLIJ_DARK_THEME="catppuccin-frappe"
K9S_LIGHT_THEME="catppuccin-latte"
K9S_DARK_THEME="catppuccin-frappe"
BAT_LIGHT_THEME="Catppuccin Latte"
BAT_DARK_THEME="Catppuccin Frappe"

COLOR_SCHEME_PREFERENCE="$1"

SED_OPTS=""
OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
    SED_OPTS="-"
fi

if [[ "$COLOR_SCHEME_PREFERENCE" == "dark" ]]; then
    echo "Enabling dark mode..."

    sed -i $SED_OPTS "s/theme \"$ZELLIJ_LIGHT_THEME\"/theme \"$ZELLIJ_DARK_THEME\"/" ~/.config/zellij/config.kdl &> /dev/null
    sed -i $SED_OPTS "s/skin:.*/skin: $K9S_DARK_THEME/g" ~/.config/k9s/config.yaml &> /dev/null
    sed -i $SED_OPTS "s/$BAT_LIGHT_THEME/$BAT_DARK_THEME/g" ~/.config/bat/config &> /dev/null

    if [[ "$OS" != "Darwin" ]]; then
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    fi
else
    echo "Enabling light mode..."

    sed -i $SED_OPTS "s/theme \"$ZELLIJ_DARK_THEME\"/theme \"$ZELLIJ_LIGHT_THEME\"/" ~/.config/zellij/config.kdl &> /dev/null
    sed -i $SED_OPTS "s/skin:.*/skin: $K9S_LIGHT_THEME/g" ~/.config/k9s/config.yaml &> /dev/null
    sed -i $SED_OPTS "s/$BAT_DARK_THEME/$BAT_LIGHT_THEME/g" ~/.config/bat/config &> /dev/null

    if [[ "$OS" != "Darwin" ]]; then
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    fi
fi

mkdir -p ~/.cache
echo "$COLOR_SCHEME_PREFERENCE" > ~/.cache/nvim-theme
