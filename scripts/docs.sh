#!/bin/sh

# Just a little script to create documentation from the scripts.

rename .sh .md scripts/*.sh
sed -E -i.sh '/^#!/d; s/^([^#])/    \1/; s/^# //' scripts/*
rename .md.sh .sh scripts/*.sh
mv scripts/*.md docs/

# Old version:

#    cd scripts
#    for script in *.sh; do
#        sed -E '/^#!/d; s/^([^#])/    \1/; s/^# //' "${script}" > "../docs/$(echo $script | cut -d. -f1).md"
#    done

# TEST

: << DOC
This is a multi-line string that doesn't need to be prefixed by '#'.
Unfortunately backticks would be interpreted, which could be dangerous.
We'd also need some state in the conversion script above.
DOC