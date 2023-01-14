---
title: Install 
---

    : << DOC
    Hello world.



    DOC

## Configure 1Password desktop

TODO

## Configure 1Password CLI

modified from `1password-cli.install` in https://aur.archlinux.org/packages/1password-cli

    getent group onepassword-cli || sudo groupadd onepassword-cli
    sudo chgrp onepassword-cli 1password/usr/bin/op
    chmod g+s 1password/usr/bin/op

## Configure and enable systemd-sysext

    mkdir -p ~/extensions
    sudo ln -s "${HOME}/extensions" /var/lib/extensions
    mv 1password.raw ~/extensions/1password.raw
    sudo systemctl enable systemd-sysext
    sudo systemctl start systemd-sysext
    systemd-sysext status

## Debugging:

    systemd-sysext status
    sudo systemd-sysext merge
    sudo systemd-sysext refresh
