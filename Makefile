ifndef CRYSTAL_BIN
	CRYSTAL_BIN = `which crystal`
endif

ifndef PREFIX
	PREFIX = $(CURDIR)/dist
endif

PRAXDIR = $(PREFIX)/opt/prax
USRBINDIR = $(PREFIX)/usr/bin
BINDIR = $(PREFIX)/opt/prax/bin
LIBDIR = $(PREFIX)/lib
INITD = $(PREFIX)/etc/init.d
DOCDIR = $(PREFIX)/opt/prax/doc
#GNOME_AUTOSTART = $(PREFIX)/usr/share/gnome/autostart
VERSION = `cat ../VERSION`

DEBIAN_DEPENDENCIES = "-d 'libpcre3' -d 'libgc1c2' -d 'libunwind8'"
#FEDORA_DEPENDENCIES = ""

SOURCES = $(wildcard src/*.cr) $(wildcard src/**/*.cr)

all: $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build $(CURDIR)/src/prax.cr -o bin/prax-binary

release: $(SOURCES)
	mkdir -p $(PREFIX)/opt/prax/bin
	$(CRYSTAL_BIN) build --release $(CURDIR)/src/prax.cr -o $(BINDIR)/prax-binary

run: all
	./bin/prax-binary

install: release
	mkdir -p $(LIBDIR) $(INITD) $(PRAXDIR) $(USRBINDIR) $(BINDIR) $(DOCDIR) #$(GNOME_AUTOSTART)
	cp bin/prax $(BINDIR)
	cp -r libexec $(PRAXDIR)
	cp install/initd $(INITD)/prax
	cp ext/libnss_prax.so.2 $(LIBDIR)
	cd $(USRBINDIR) && ln -sf ../../opt/prax/bin/prax
	cp README.md LICENSE install/prax.desktop $(DOCDIR)
	#cp install/prax.desktop $(GNOME_AUTOSTART)
	chmod -R 0755 $(PRAXDIR)/bin $(PRAXDIR)/libexec $(LIBDIR)/libnss_prax.so.2 $(INITD)/prax

package: install
	cd dist && fpm -s dir -t $(TARGET) -n "prax" -v $(VERSION) $(DEPENDENCIES) \
		--maintainer "julien@portalier.com" \
		--url "https://github.com/ysbaddaden/prax.cr" \
		--description "Rack Proxy Server" \
		--vendor "" \
		--license "CeCILL 2.1 License" \
		--category devel \
		--after-install "../install/postinst" \
		--before-remove "../install/prerm" \
		etc lib opt usr

deb:
	TARGET=deb DEPENDENCIES=$(DEBIAN_DEPENDENCIES) make package
	mkdir -p packages
	mv dist/*.deb packages/

#rpm:
#	TARGET=rpm make package

clean:
	rm -rf dist
