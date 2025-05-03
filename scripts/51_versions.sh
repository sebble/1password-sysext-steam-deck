#!/bin/sh
# ---
# title: Update versions
# ---

# Update the 'latest' versions listed in various files.

# ```shell
echo '{}' > ./versions.json

## Steam OS
VERSION_ID="$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2)"
jq ".versions.steam_os.version_id = \"${VERSION_ID}\"" ./versions.json > versions.tmp && mv versions.tmp versions.json
BUILD_ID="$(grep -E '^BUILD_ID=' /etc/os-release | cut -d= -f2)"
jq ".versions.steam_os.build_id = \"${BUILD_ID}\"" ./versions.json > versions.tmp && mv versions.tmp versions.json

## 1Password
jq ".versions.\"1password\".cli = \"$(op --version)\"" ./versions.json > versions.tmp && mv versions.tmp versions.json
jq ".versions.\"1password\".desktop = \"$(1password --version)\"" ./versions.json > versions.tmp && mv versions.tmp versions.json
jq ".versions.\"1password\".desktop_build = \"TODO\"" ./versions.json > versions.tmp && mv versions.tmp versions.json # Requires manual update

## Firefox
FIREFOX_VERSION="$(flatpak list --columns=application,version | grep org.mozilla.firefox | cut -f2)"
jq ".versions.firefox.flatpak = \"${FIREFOX_VERSION}\"" ./versions.json > versions.tmp && mv versions.tmp versions.json
# ```
