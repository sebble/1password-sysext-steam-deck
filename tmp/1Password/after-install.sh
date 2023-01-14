#!/bin/sh
set -eu

CHANNEL="stable"
PLATFORM="tar"
  
# This script requires a header.

ONEPASSWORD_KEY_URL="https://downloads.1password.com/linux/keys/1password.asc"

installDebChannel() {
  echo "Installing the debian auto-update channel"
  # XXXX: Commands reaching out over the network output into a tempfile and move into the final
  #       location once we know everything is ok. This avoids breaking existing installs if the
  #       network is lost or we deploy a change while a client is applying their downloaded update.
  #       If a client hits this condition, apt will report that there was an error but should
  #       succeed the next time the update is installed (if the network is back up).
  TEMPDIR=$(mktemp -d)
  curl -fsS "$ONEPASSWORD_KEY_URL" | gpg --dearmor --output "$TEMPDIR/1password.gpg"
  curl -fsSo "$TEMPDIR/1password.pol" https://downloads.1password.com/linux/debian/debsig/1password.pol

  # Setup apt repository
  cp "$TEMPDIR/1password.gpg" /usr/share/keyrings/1password-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 ${CHANNEL} main" > /etc/apt/sources.list.d/1password.list

  # Setup debsig verification
  mkdir -p /etc/debsig/policies/AC2D62742012EA22/
  mv "$TEMPDIR/1password.pol" /etc/debsig/policies/AC2D62742012EA22/1password.pol

  mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22/
  mv "$TEMPDIR/1password.gpg" /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

  rm -rf "$TEMPDIR"
}

installRpmChannel() {
  case $CHANNEL in
    "stable")
      NAME="1Password Stable Channel"
      ;;

    "beta")
      NAME="1Password Beta Channel"
      ;;

    "edge")
      NAME="1Password Edge Channel"
      ;;

    *)
      NAME="1Password"
      ;;
  esac

  # repo_gpgcheck is disabled(system default)
  # This is due to DNF not using keys that have been imported.
  # Package signatures are still verified due to gpgcheck=1
  # https://bugzilla.redhat.com/show_bug.cgi?id=1768206
  if [ -d /etc/yum.repos.d ]; then
    cat > /etc/yum.repos.d/1password.repo <<- EOM
[1password]
name="$NAME"
baseurl=https://downloads.1password.com/linux/rpm/${CHANNEL}/\$basearch
enabled=1
gpgcheck=1
#repo_gpgcheck=1
gpgkey="$ONEPASSWORD_KEY_URL"
EOM
  fi

  if [ -d /etc/zypp ]; then
    cat > /etc/zypp/repos.d/1password.repo <<- EOM
[1password]
name="$NAME"
baseurl=https://downloads.1password.com/linux/rpm/${CHANNEL}/\$basearch
enabled=1
gpgcheck=1
autorefresh=1
#repo_gpgcheck=1
gpgkey=$ONEPASSWORD_KEY_URL
EOM
  fi
}

installAutoupdateChannel() {
  if [ "$PLATFORM" = "rpm" ]; then
    installRpmChannel
  elif [ "$PLATFORM" = "deb" ]; then
    installDebChannel
  fi
}

installFiles() {
  CWD=$(pwd)
  cd /opt/1Password/

  # Fill in policy kit file with a list of (the first 10) human users of the system.
  export POLICY_OWNERS
  POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"
  eval "cat <<EOF
$(cat ./com.1password.1Password.policy.tpl)
EOF" > ./com.1password.1Password.policy

  # Install policy kit file for system unlock
  install -Dm0644 ./com.1password.1Password.policy -t /usr/share/polkit-1/actions/

  # Install examples
  install -Dm0644 ./resources/custom_allowed_browsers -t /usr/share/doc/1password/examples/

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

  chgrp "${GROUP_NAME}" $HELPER_PATH
  # The binary requires setuid so it may interact with the Kernel keyring facilities
  chmod u+s $HELPER_PATH
  chmod g+s $HELPER_PATH

  # This gives no extra permissions to the binary. It only hardens it against environmental tampering.
  chgrp "${GROUP_NAME}" $BROWSER_SUPPORT_PATH
  chmod g+s $BROWSER_SUPPORT_PATH

  # Restore previous directory
  cd "$CWD"

  # Register path symlink
  ln -sf /opt/1Password/1password /usr/bin/1password
}

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be running as root to run 1Password's post-installation process"
  exit
fi

installFiles
installAutoupdateChannel

exit 0
