#!/bin/bash

set -xe

sudo tee -a /etc/zshrc << EOF
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; 
then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
EOF


