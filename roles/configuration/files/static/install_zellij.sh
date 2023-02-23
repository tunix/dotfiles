#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"
DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/zellij-org/zellij/releases/latest \
    | jq -r '.assets[] | select(.name | test("zellij-'${ARCHITECTURE/arm64/aarch64}'.*'${KERNEL,,}'.*tar.gz")) | .browser_download_url')

curl -L $DOWNLOAD_URL | tar zxvf - -C $BINARY_PATH zellij

chmod +x $BINARY_PATH/zellij
