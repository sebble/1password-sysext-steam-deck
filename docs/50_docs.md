---
title: Docs
---

Just a little script to create documentation from the scripts. For actual documentation, see the other pages.

This little script:
1.  Renames the `.sh` files to `.md` in `scripts/`
2.  Converts the files (and creates a 'backup' called `.md.sh`)
    -   Deletes the shebang
    -   <s>Indents all non-commented, non-empty lines</s>
    -   Strips "`# `" from the start of every line
3.  Renames the `.md.sh` files back to `.sh`
4.  Moves the `.md` files in `scripts/` to `docs/`

^

```shell
rename .sh .md scripts/*.sh
sed -E -i.sh '/^#!/d; s/^# //' scripts/*
rename .md.sh .sh scripts/*.sh
mv scripts/*.md docs/
```

Old (and simpler) version:

```shell
cd scripts
for script in *.sh; do
    sed -E '/^#!/d; s/^([^#])/    \1/; s/^# //' "${script}" > "../docs/$(echo $script | cut -d. -f1).md"
done
```

And here is a concept of another potential '[literate](https://en.wikipedia.org/wiki/Literate_programming)' format.
Although this whole script is kind of the opposite.

```shell
: << DOC
This is a multi-line string that doesn't need to be prefixed by '#'.
Unfortunately backticks would be interpreted, which could be dangerous.
We'd also need some state in the conversion script above.
DOC
```

### And update the versions..
VERSION_ID="$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2)"
jq ".versions.steam_os.version_id = \"${VERSION_ID}\"" ./scripts/versions.json | tee ./scripts/versions.json

BUILD_ID="$(grep -E '^BUILD_ID=' /etc/os-release | cut -d= -f2)"
jq ".versions.steam_os.build_id = \"${BUILD_ID}\"" ./scripts/versions.json | tee ./scripts/versions.json
