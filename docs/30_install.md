---
title: Install 
---
<!-- hide the `ex` bits, they're only useful in this script
set -ex
-->

Try `make install`.

## Configure 1Password desktop

No additional runtime configuration is currently required for the Desktop application.
This may change while addressing the outstanding feature requests and bugs.

## Configure 1Password CLI

The following is modified from `1password-cli.install` in <https://aur.archlinux.org/packages/1password-cli>.
Alternatively, the instructions for official, manual installation also suggest these commands.

We are:
-   Creating the `onepassword-cli` group if it does not exist
-   Ensuring that the `op` CLI binary is owned by the `onepassword-cli` group
-   Enabling `setgid` bit on the binary, to ensure that it runs under the `onepassword-cli` group (this is important for biometrics)

```shell
getent group onepassword-cli || sudo groupadd onepassword-cli
```

## Configure and enable systemd-sysext

We want the system extension to stay on a Steam Deck partition that will not be wiped.
For this reason we are creating a folder for such extensions in our home directory (suggestion from <https://blogs.igalia.com/berto/2022/09/13/adding-software-to-the-steam-deck-with-systemd-sysext/>).
With a suitable location for our system image layer, we move the built `.raw` file and create a symlink to our extension directory from the expected location on the real OS.

```shell
mkdir -p ~/extensions
test -L /var/lib/extensions || \
    sudo ln -sf "${HOME}/extensions" /var/lib/extensions
mv build/extensions/1password.raw ~/extensions/1password.raw
sudo systemctl enable systemd-sysext
sudo systemctl start systemd-sysext
sudo systemd-sysext refresh
systemd-sysext status
```

## Debugging:

    systemd-sysext status
    sudo systemd-sysext merge
    sudo systemd-sysext refresh
