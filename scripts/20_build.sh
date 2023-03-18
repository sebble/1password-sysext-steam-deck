#!/bin/sh
# ---
# title: Build
# ---
# <!-- hide the `ex` bits, they're only useful in this script
set -ex
# -->

# Try `make build` or `make`.

# We provide a name for the `sysext` that we are going to build.

# ```shell
SYSEXT_PREFIX=1password
SYSTEXT_PATH="build/extensions/${SYSEXT_PREFIX}"
# ```

# Before we do anything else we also need to ensure everything in opt is owned by `root` (for the later `setuid` bits to work).

# ```shell
sudo chown -R root:root ${SYSTEXT_PATH}
# ```

# The following is almost identical to `/opt/1Password/after-install.sh` in official desktop download archive.
# We have prefixed all absolute paths with `SYSEXT_PREFIX`, and added some `root` ownership checks.

# We also replace a nested `eval/cat/cat` with `envsubst`, using `tee` to allow us to write with `sudo`.
# This could also be achieved with a `sed`, especially as we know the username is always `deck`.

# Lastly, let's create a few directories ahead of time.

# ```shell
sudo mkdir -p ${SYSTEXT_PATH}/usr/share/bin/
sudo mkdir -p ${SYSTEXT_PATH}/usr/share/polkit-1/actions/
sudo mkdir -p ${SYSTEXT_PATH}/usr/share/doc/1password/examples/
sudo mkdir -p ${SYSTEXT_PATH}/usr/share/applications/
sudo mkdir -p ${SYSTEXT_PATH}/usr/lib/extension-release.d/
# ```

# The mostly original install script:

# ```shell
installFiles() {
  CWD=$(pwd)
  cd ${SYSTEXT_PATH}/opt/1Password/

  # Fill in policy kit file with a list of (the first 10) human users of the system.
  export POLICY_OWNERS
  POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"
  cat com.1password.1Password.policy.tpl | envsubst | sudo tee ./com.1password.1Password.policy

  # Install policy kit file for system unlock
  sudo install -Dm0644 ./com.1password.1Password.policy -t ../../usr/share/polkit-1/actions/

  # Install examples
  sudo install -Dm0644 ./resources/custom_allowed_browsers -t ../../usr/share/doc/1password/examples/

  # chrome-sandbox requires the setuid bit to be specifically set.
  # See https://github.com/electron/electron/issues/17972
  sudo chmod 4755 ./chrome-sandbox

  GROUP_NAME="onepassword"

  # Setup the Core App Integration helper binary with the correct permissions and group
  if [ ! "$(getent group "${GROUP_NAME}")" ]; then
    groupadd "${GROUP_NAME}"
  fi

  HELPER_PATH="./1Password-KeyringHelper"
  BROWSER_SUPPORT_PATH="./1Password-BrowserSupport"

  sudo chgrp "${GROUP_NAME}" $HELPER_PATH
  # The binary requires setuid so it may interact with the Kernel keyring facilities
  sudo chmod u+s $HELPER_PATH
  sudo chmod g+s $HELPER_PATH

  # This gives no extra permissions to the binary. It only hardens it against environmental tampering.
  sudo chgrp "${GROUP_NAME}" $BROWSER_SUPPORT_PATH
  sudo chmod g+s $BROWSER_SUPPORT_PATH

  # Restore previous directory
  cd "$CWD"

  # Register path symlink
  sudo ln -sf ../../opt/1Password/1password ${SYSTEXT_PATH}/usr/bin/1password
}

installFiles
#installAutoupdateChannel ## Not implemented
# ```

## Add application (enables browser integration and launcher menu item)

# ```shell
sudo cp ${SYSTEXT_PATH}/opt/1Password/resources/1password.desktop ${SYSTEXT_PATH}/usr/share/applications/
# ```

## Configure 1Password CLI

# For the CLI to work we must ensure that it is in the correct group. This enables the `setgid` bit to do some magic.

# ```shell
sudo chgrp onepassword-cli ${SYSTEXT_PATH}/usr/bin/op
sudo chmod g+s ${SYSTEXT_PATH}/usr/bin/op
# ```

#     gpg --receive-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22
#     gpg --verify op.sig op

## Configure systemd-sysext

# ```shell
VERSION_ID="$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2)"
echo "ID=steamos" | sudo tee ${SYSTEXT_PATH}/usr/lib/extension-release.d/extension-release.${SYSEXT_PREFIX}
echo "VERSION_ID=${VERSION_ID}" | sudo tee -a ${SYSTEXT_PATH}/usr/lib/extension-release.d/extension-release.${SYSEXT_PREFIX}
# ```

## Create the filesystem layer

# ```shell
rm -f ${SYSTEXT_PATH}.raw
mksquashfs ${SYSTEXT_PATH} ${SYSTEXT_PATH}.raw
# ```

# Next: [Install](install)
