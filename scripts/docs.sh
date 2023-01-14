#!/bin/sh

cd scripts

for script in *.sh; do
    sed '/^#!/d; /^[^#]/d; s/^# //' "${script}" > "../docs/$(echo $script | cut -d. -f1).md"
done
