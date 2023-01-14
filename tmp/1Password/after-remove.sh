#!/bin/sh
set -eu

CHANNEL="stable"
PLATFORM="tar"
  
# This script requires a header.

# https://wiki.debian.org/MaintainerScripts
# https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be running as root to run 1Password's post-uninstallation process"
  exit
fi

if [ "$PLATFORM" = "rpm" ] && [ "${1:-0}" -gt 0 ]; then
  # RPM Upgrade in progress, keep existing files.
  # This script is run from the old version
  # after the post install has run on the new version.
  exit
fi

# Remove policy kit file for system unlock
rm -f /usr/share/polkit-1/actions/com.1password.1Password.policy
# Remove docs
rm -rf /usr/share/doc/1password
# Cleanup symlink
rm -f /usr/bin/1password

exit 0
