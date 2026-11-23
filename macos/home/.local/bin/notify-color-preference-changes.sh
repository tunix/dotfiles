#!/usr/bin/env bash

mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

if [[ "$mode" == "Dark" ]]; then
    ~/.local/bin/toggle-color-preferences.sh dark
else
    ~/.local/bin/toggle-color-preferences.sh light
fi
