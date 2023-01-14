#!/bin/bash

set -eu
set -o pipefail

POLICY_FILE="com.1password.1Password.policy"
POLKIT_DIR="/usr/share/polkit-1/actions/"

DEST="$POLKIT_DIR$POLICY_FILE"

if [[ -f $DEST && ${1-n} != "-f" ]]; then
    echo "PolKit policy is already installed. Exiting"
    echo "If you need to overwrite the current one, please run the script again with an argument of '-f'"
    exit
fi

if [ $(id -u) -ne 0 ]; then
    echo "You must be running as root to install PolKit policies"
    exit
fi

if [ ! -d $POLKIT_DIR ]; then
    echo "PolKit is not present on your system, policy cannot be installed"
    exit
fi

# Fill in policy kit file with a list of (the first 10) human users of the system.
export POLICY_OWNERS
POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"
eval "cat <<EOF
$(cat ./com.1password.1Password.policy.tpl)
EOF" > ./com.1password.1Password.policy

LOCAL_POLICY_FILE="./$POLICY_FILE"

if [ ! $LOCAL_POLICY_FILE ]; then
    echo "Unable to find PoklKit policy file. Try re-downloading the distribution"
    exit
fi

echo "Copying $LOCAL_POLICY_FILE to $DEST"

cp $LOCAL_POLICY_FILE $DEST
