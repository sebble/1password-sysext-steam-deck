#!/bin/sh
# ---
# title: Download
# ---
# <!-- hide the `ex` bits, they're only useful in this script
set -ex
# -->

# Try `make download` or `make`.

## Prepare sysext location

# We provide a name for the `sysext` that we are going to build.

# ```shell
SYSEXT_PREFIX=1password
SYSTEXT_PATH="build/extensions/${SYSEXT_PREFIX}"
# ```

## Download 1Password desktop

# Start by downloading the offical 1Password release archive. We will install this into our sysext.

# ```shell
mkdir -p tmp
curl https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz -o tmp/1password-latest.tar.gz
# ```

# TODO: verify the GPG signature of this download.

## Download 1Password CLI

# Detect latest download URL for 1Password CLI 

# ```shell
URL="$(curl -s 'https://app-updates.agilebits.com/product_history/CLI2' | grep -oE 'https://[^"]+linux_amd64[^"]+\.zip' | grep -v beta | head -1)"
wget "${URL}" -O tmp/op.zip
# ```

## Download 1Password CLI scripts

# This is used for development (checking the post-install requirements).

# ```shell
git clone https://aur.archlinux.org/1password-cli.git tmp/1password-cli
# ```

## Download the 1Password Debian package

# TODO: This has more resources than the AUR package for some reason. Use this in the future?

# ```shell
curl https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb -o tmp/1password-latest.deb
#(cd tmp && ar x 1password-latest.deb)
#tar -C tmp -xf tmp/control.tar.gz ./postinst
#tar -C tmp/deb-data -xf tmp/data.tar.xz
#tree tmp/1password-8.10.3.x64/ > scripts/aur.tree
#tree tmp/deb-data/ > scripts/deb.tree
# ````

# Next: [Build](build)
