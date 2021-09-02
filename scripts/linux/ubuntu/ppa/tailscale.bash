#!/bin/bash
# vim:set ft=bash et sw=4:

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).list | sudo tee /etc/apt/sources.list.d/tailscale.list
