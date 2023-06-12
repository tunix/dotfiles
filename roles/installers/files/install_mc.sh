#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"

curl -L "https://dl.min.io/client/mc/release/${KERNEL,,}-${ARCHITECTURE/x86_64/amd64}/mc" \
    -o $BINARY_PATH/mc

chmod +x $BINARY_PATH/mc
