#!/usr/bin/env bash

ARCHITECTURE=$(uname -m)
KERNEL=$(uname -s)
BINARY_PATH="$HOME/.local/bin"
LATEST_RELEASE=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -L "https://dl.k8s.io/release/$LATEST_RELEASE/bin/${KERNEL,,}/${ARCHITECTURE/x86_64/amd64}/kubectl" \
    -o $BINARY_PATH/kubectl

chmod +x $BINARY_PATH/kubectl
