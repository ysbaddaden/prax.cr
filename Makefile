CRYSTAL = /home/julien/work/github/crystal/bin/crystal

all:
	mkdir -p bin
	$(CRYSTAL) build src/prax.cr -o bin/prax-binary

run: all
	./bin/prax-binary

release:
	mkdir -p bin
	$(CRYSTAL) build --release src/prax.cr -o bin/prax-binary

