#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"

DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/sigstore/cosign/releases/latest \
    | jq -r '.assets[] | select(.name | test("cosign-'${KERNEL,,}'-'${ARCHITECTURE/x86_64/amd64}'$")) | .browser_download_url')

curl -L $DOWNLOAD_URL -o $BINARY_PATH/cosign

chmod +x $BINARY_PATH/cosign
