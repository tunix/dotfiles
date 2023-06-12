#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
BINARY_PATH="$HOME/.local/bin"

curl -L "https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE/arm64/aarch64}.zip" \
    -o /tmp/awscli.zip

unzip -u /tmp/awscli.zip -d /tmp

/tmp/aws/install -u -i ~/.local/share/aws-cli -b ~/.local/bin
