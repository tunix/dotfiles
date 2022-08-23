#!/bin/bash

DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/ahmetb/kubectx/releases/latest | jq -r '.assets[] | select(.name == "kubens") | .browser_download_url')

curl -L $DOWNLOAD_URL -o /usr/local/bin/kubens

chmod +x /usr/local/bin/kubens
