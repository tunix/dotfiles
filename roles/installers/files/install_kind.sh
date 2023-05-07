#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"
DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/kubernetes-sigs/kind/releases/latest \
    | jq -r '.assets[] | select(.name | test("kind-'${KERNEL,,}'-'${ARCHITECTURE/x86_64/amd64}'$")) | .browser_download_url')

curl -L $DOWNLOAD_URL -o $BINARY_PATH/kind

chmod +x $BINARY_PATH/kind
