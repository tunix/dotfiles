#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"
DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/ahmetb/kubectx/releases/latest \
    | jq -r '.assets[] | select(.name | test("kubens.*'${KERNEL,,}'_'$ARCHITECTURE'")) | .browser_download_url')

curl -L $DOWNLOAD_URL | tar zxvf - -C $BINARY_PATH kubens

chmod +x $BINARY_PATH/kubens
