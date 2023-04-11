#!/usr/bin/env bash

GOLANG_VERSION=1.20.3
ARCHITECTURE=$(uname -m)
SDK_HOME="$HOME/sdk"
SDK_PATH="$SDK_HOME/go${GOLANG_VERSION}"
DOWNLOAD_URL="https://go.dev/dl/go${GOLANG_VERSION}.linux-${ARCHITECTURE/x86_64/amd64}.tar.gz"

if [[ -d $SDK_PATH ]]; then
    echo "golang $GOLANG_VERSION is already installed."

    exit 0
fi

mkdir -p $SDK_PATH

curl -L $DOWNLOAD_URL | tar zxvf - -C $SDK_PATH --strip-components 1

ln -sf $SDK_PATH $SDK_HOME/go
