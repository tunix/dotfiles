#!/usr/bin/env bash

export ARCHITECTURE=$(uname -m)
export KERNEL=$(uname -s)
export BINARY_PATH="$HOME/.local/bin"
export DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/wagoodman/dive/releases/latest \
    | jq -r '.assets[] | select(.name | test("dive_.*'${KERNEL,,}'_'${ARCHITECTURE/x86_64/amd64}'.tar.gz")) | .browser_download_url')

curl -L $DOWNLOAD_URL | tar zxvf - -C $BINARY_PATH dive

chmod +x $BINARY_PATH/dive
