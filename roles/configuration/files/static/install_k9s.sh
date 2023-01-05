#!/bin/bash

export ARCHITECTURE=$(uname -m)
export KERNEL=$(uname -s)
export BINARY_PATH="$HOME/.local/bin"
export DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/derailed/k9s/releases/latest \
    | jq -r '.assets[] | select(.name == "k9s_'$KERNEL'_'$ARCHITECTURE'.tar.gz") | .browser_download_url')

curl -L $DOWNLOAD_URL | tar zxvf - -C $BINARY_PATH k9s

chmod +x $BINARY_PATH/k9s
