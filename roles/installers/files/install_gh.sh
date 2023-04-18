#!/usr/bin/env bash

export ARCHITECTURE=$(uname -m)
export KERNEL=$(uname -s)
export BINARY_PATH="$HOME/.local/bin"
export DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/cli/cli/releases/latest \
    | jq -r '.assets[] | select(.name | test("gh_.*_'${KERNEL,,}'_'${ARCHITECTURE/x86_64/amd64}'.tar.gz")) | .browser_download_url')

curl -L $DOWNLOAD_URL | tar zxvf - -C $BINARY_PATH --strip-components=2 '*/bin/gh'

chmod +x $BINARY_PATH/gh
