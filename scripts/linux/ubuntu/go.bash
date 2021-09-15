#!/bin/bash
# vim:set ft=bash et sw=4:

GO_VERSION="1.17.1"
GO_DOWNLOAD_URL="https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"

GH="\$HOME/.local/lib/go"
GP="\$HOME/.go"
GOHOME="$(eval echo $GH)"
GOPATH="$(eval echo $GP)"

delete "$GOHOME" \
    && download $GO_DOWNLOAD_URL /tmp/go.tar.gz \
    && mkdir -p "$GOHOME" "$GOPATH" \
    && tar -C $(dirname "$GOHOME") -xzf /tmp/go.tar.gz

cat <<EOF > "$GOPATH/env"
export GOHOME="$GH"
export GOPATH="$GP"
export PATH="\$PATH:\$GOHOME/bin:\$GOPATH/bin"
EOF

if ! grep -q "$GP/env" $HOME/.profile; then
    echo ". \"$GP/env\"" >> $HOME/.profile
fi
