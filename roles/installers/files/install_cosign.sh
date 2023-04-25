#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"

if [[ "$ARCHITECTURE" == "arm64" ]]; then
    ARCHITECTURE="aarch64"
else
    ARCHITECTURE="amd64"
fi

DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/sigstore/cosign/releases/latest \
    | jq -r '.assets[] | select(.name | test("cosign-'${KERNEL,,}'-'${ARCHITECTURE}'$")) | .browser_download_url')

curl -L $DOWNLOAD_URL -o $BINARY_PATH/cosign

chmod +x $BINARY_PATH/cosign
