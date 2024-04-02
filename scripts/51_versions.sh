#!/bin/sh
# ---
# title: Update versions
# ---

# Update the 'latest' versions listed in various files.

# ```shell
echo '{}' > ./versions.json

VERSION_ID="$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2)"
jq ".versions.steam_os.version_id = \"${VERSION_ID}\"" ./versions.json > versions.tmp && mv versions.tmp versions.json

BUILD_ID="$(grep -E '^BUILD_ID=' /etc/os-release | cut -d= -f2)"
jq ".versions.steam_os.build_id = \"${BUILD_ID}\"" ./versions.json > versions.tmp && mv versions.tmp versions.json

jq ".versions.\"1password\".cli = \"$(op --version)\"" ./versions.json > versions.tmp && mv versions.tmp versions.json

FIREFOX_VERSION="$(flatpak list --columns=application,version | grep org.mozilla.firefox | cut -f2)"
jq ".versions.firefox.flatpak = \"${FIREFOX_VERSION}\"" ./versions.json > versions.tmp && mv versions.tmp versions.json
# ```
