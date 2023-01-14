#!/bin/sh
# ---
# title: Download
# ---

# Try `make download` or `make`.

## Download 1Password desktop

# Start by downloading the offical 1Password release archive. We will install this into our sysext.

# ```shell
curl -sSO https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz
tar -xf 1password-latest.tar.gz
# ```

# TODO: verify the GPG signature of this download.

# Next we will copy the contents into a the location they would normally be extracted to, but inside our `sysext` file system.

# ```shell
mkdir -p 1password/opt
mv 1password-* 1password/opt/1Password
rm 1password-latest.tar.gz
# ```

## Download 1Password CLI

# ```shell
ARCH="amd64" # choose between 386/amd64/arm/arm64
VERSION="2.12.0"
wget "https://cache.agilebits.com/dist/1P/op2/pkg/v${VERSION}/op_linux_${ARCH}_v${VERSION}.zip" -O op.zip
unzip -d op op.zip
mkdir -p 1password/usr/bin
mv op 1password/usr/bin/
# ```

## Download 1Password CLI scripts

# ```shell
git clone https://aur.archlinux.org/1password-cli.git
# ```

# Next: [Build](build)
