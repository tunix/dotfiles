#!/bin/bash
# vim:set ft=bash et sw=4:

sudo snap install bpytop

sudo snap connect bpytop:mount-observe
sudo snap connect bpytop:network-control
sudo snap connect bpytop:hardware-observe
sudo snap connect bpytop:system-observe
sudo snap connect bpytop:process-control
sudo snap connect bpytop:physical-memory-observe

sudo snap install http
sudo snap install yq
sudo snap install hugo --edge
sudo snap install gradle --candidate
sudo snap install kubectl
sudo snap install obs-studio
sudo snap install snapcraft
sudo snap install snappy-debug
sudo snap install review-tools

# TODO: nodejs
# TODO: obs connectons
