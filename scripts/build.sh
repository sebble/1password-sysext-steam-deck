#!/bin/sh
# ---
# title: Build
# ---

# Try `make build` or `make`.

# We provide a name for the `sysext` that we are going to build.

# ```shell
SYSEXT_PREFIX=1password
# ```

# modified from `/opt/1Password/after-install.sh` in official desktop download archive

# ```shell
installFiles() {
  CWD=$(pwd)
  cd ${SYSEXT_PREFIX}/opt/1Password/

  # Fill in policy kit file with a list of (the first 10) human users of the system.
  export POLICY_OWNERS
  POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"
  eval "cat <<EOF
$(cat ./com.1password.1Password.policy.tpl)
EOF" > ./com.1password.1Password.policy

  # Install policy kit file for system unlock
  install -Dm0644 ./com.1password.1Password.policy -t ${SYSEXT_PREFIX}/usr/share/polkit-1/actions/

  # Install examples
  install -Dm0644 ./resources/custom_allowed_browsers -t ${SYSEXT_PREFIX}/usr/share/doc/1password/examples/

  # chrome-sandbox requires the setuid bit to be specifically set.
  # See https://github.com/electron/electron/issues/17972
  chmod 4755 ./chrome-sandbox

  GROUP_NAME="onepassword"

  # Setup the Core App Integration helper binary with the correct permissions and group
  if [ ! "$(getent group "${GROUP_NAME}")" ]; then
    groupadd "${GROUP_NAME}"
  fi

  HELPER_PATH="./1Password-KeyringHelper"
  BROWSER_SUPPORT_PATH="./1Password-BrowserSupport"

  sudo chgrp "${GROUP_NAME}" $HELPER_PATH
  # The binary requires setuid so it may interact with the Kernel keyring facilities
  chmod u+s $HELPER_PATH
  chmod g+s $HELPER_PATH

  # This gives no extra permissions to the binary. It only hardens it against environmental tampering.
  sudo chgrp "${GROUP_NAME}" $BROWSER_SUPPORT_PATH
  chmod g+s $BROWSER_SUPPORT_PATH

  # Restore previous directory
  cd "$CWD"

  # Register path symlink
  ln -sf ../../opt/1Password/1password ${SYSEXT_PREFIX}/usr/bin/1password
}

installFiles
#installAutoupdateChannel ## Not implemented
# ```

## Add application (enables browser integration and launcher menu item)

# ```shell
cp ${SYSEXT_PREFIX}/opt/1Password/resources/1password.desktop ${SYSEXT_PREFIX}/usr/share/applications/
# ```

## Configure 1Password CLI

# TODO

#     gpg --receive-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22
#     gpg --verify op.sig op

## Configure systemd-sysext

# ```shell
VERSION_ID="$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2)"
echo "ID=steamos" > ${SYSEXT_PREFIX}/usr/lib/extension-release.d/extension-release.${SYSEXT_PREFIX}
echo "VERSION_ID=${VERSION_ID}" >> ${SYSEXT_PREFIX}/usr/lib/extension-release.d/extension-release.${SYSEXT_PREFIX}
# ```

## Create the filesystem layer

# ```shell
mksquashfs ${SYSEXT_PREFIX} ${SYSEXT_PREFIX}.raw
# ```
