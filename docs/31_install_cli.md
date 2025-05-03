---
title: Install CLI
---
<!-- hide the `ex` bits, they're only useful in this script
set -ex
-->

## Install OP CLI into local user path for, e.g., VSCode Flatpak

By copying the OP CLI into ~/.local/bin it is accessible inside Flatpaks that can access the user home directory.

```shell
cp /usr/bin/op ~/.local/bin
```
