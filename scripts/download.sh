#!/bin/sh

## Download 1Password desktop
curl -sSO https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz
tar -xf 1password-latest.tar.gz
mkdir -p 1password/opt
mv 1password-* 1password/opt/1Password
rm 1password-latest.tar.gz

## Download 1Password CLI
ARCH="amd64" # choose between 386/amd64/arm/arm64
VERSION="2.12.0"
wget "https://cache.agilebits.com/dist/1P/op2/pkg/v${VERSION}/op_linux_${ARCH}_v${VERSION}.zip" -O op.zip
unzip -d op op.zip
mkdir -p 1password/usr/bin
mv op 1password/usr/bin/

## Download 1Password CLI scripts
git clone https://aur.archlinux.org/1password-cli.git
