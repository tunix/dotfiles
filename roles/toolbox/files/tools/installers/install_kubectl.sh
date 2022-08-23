#!/bin/bash

LATEST_RELEASE=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -L "https://dl.k8s.io/release/$LATEST_RELEASE/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl

chmod +x /usr/local/bin/kubectl
