all: download build

download:
	./scripts/download.sh

build:
	./scripts/build.sh

install:
	./scripts/install.sh
