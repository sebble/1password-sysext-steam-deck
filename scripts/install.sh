#!/bin/sh

## Configure 1Password desktop
# TODO

## Configure 1Password CLI
# modified from `1password-cli.install` in https://aur.archlinux.org/packages/1password-cli
getent group onepassword-cli || sudo groupadd onepassword-cli
sudo chgrp onepassword-cli 1password/usr/bin/op
chmod g+s 1password/usr/bin/op
