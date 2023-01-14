#!/bin/sh

# Just a little script to create documentation from the scripts.

cd scripts
for script in *.sh; do
    sed -E '/^#!/d; s/^([^#])/    \1/; s/^# //' "${script}" > "../docs/$(echo $script | cut -d. -f1).md"
done
