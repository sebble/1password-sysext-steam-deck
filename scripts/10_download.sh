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
tar -C tmp -xf tmp/1password-latest.tar.gz
# ```

# TODO: verify the GPG signature of this download.

# Next we will copy the contents into a the location they would normally be extracted to, but inside our `sysext` file system.

# ```shell
mkdir -p "${SYSTEXT_PATH}/opt"
mv tmp/1password-*.x64 "${SYSTEXT_PATH}/opt/1Password"
# ```

## Download 1Password CLI

# Detect latest download URL for 1Password CLI 

# ```shell
URL="$(curl -s 'https://app-updates.agilebits.com/product_history/CLI2' | grep -oE 'https://[^"]+linux_amd64[^"]+\.zip' | grep -v beta | head -1)"
# ```

# ```shell
#ARCH="amd64" # choose between 386/amd64/arm/arm64
#VERSION="2.15.0"
#URL="https://cache.agilebits.com/dist/1P/op/pkg/v${VERSION}/op_linux_${ARCH}_v${VERSION}.zip"
wget "${URL}" -O tmp/op.zip
mkdir -p "${SYSTEXT_PATH}/usr/bin"
unzip -d "${SYSTEXT_PATH}/usr/bin" tmp/op.zip -x op.sig
# ```

## Download 1Password CLI scripts

# This is used for development (checking the post-install requirements).

# ```shell
git clone https://aur.archlinux.org/1password-cli.git tmp/1password-cli
# ```

## Download the 1Password Debian package

# TODO: This has more resources than the AUR package for some reason. Use this in the future?

# Next: [Build](build)
