.PHONY: all download build install docs clean

all: download build

download:
	./scripts/10_download.sh

build:
	./scripts/20_build.sh

install:
	./scripts/30_install.sh

docs:
	./scripts/50_docs.sh

hooks: .git/hooks/pre-commit
	ln -s -f ../../hooks/pre-commit .git/hooks/pre-commit

clean:
	./scripts/90_clean.sh