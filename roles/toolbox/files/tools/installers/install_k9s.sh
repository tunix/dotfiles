#!/bin/bash

DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.assets[] | select(.name == "k9s_Linux_x86_64.tar.gz") | .browser_download_url')

curl -L $DOWNLOAD_URL -o /tmp/k9s.tar.gz
tar zxvf /tmp/k9s.tar.gz -C /usr/local/bin k9s
chown root:root /usr/local/bin/k9s
chmod +x /usr/local/bin/k9s
