#!/bin/bash
# vim:set ft=bash et sw=4:

pushd /usr/share/doc/git/contrib/credential/libsecret

sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret

git config \
    --file $HOME/.gitconfig.inc \
    credential.helper \
   /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

popd
