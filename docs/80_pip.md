---
title: Install Pre-Commit
---
<!-- hide the `ex` bits, they're only useful in this script
set -ex
-->

## Install pre-commit (and pipx)

This seems a bit dodgy but I'm experimenting.

```shell
python -m venv ~/.local # this was an accident but it kind of worked..
source ~/.local/bin/activate
pip install -U pip
pip install pipx
deactivate
pipx install pre-commit
pre-commit install
```
