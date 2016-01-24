CRYSTAL_BIN ?= $(shell which crystal)

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

#DEB_DEPENDENCIES = "-d 'libpcre3' -d 'libgc1c2' -d 'libunwind8 | libunwind7'"
DEB_DEPENDENCIES = "-d 'libssl1.0.0'"

SOURCES = $(wildcard src/*.cr) $(wildcard src/**/*.cr)

.PHONY: ext

all: $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build $(CURDIR)/src/prax.cr -o bin/prax-binary

release: $(SOURCES)
	mkdir -p $(BINDIR)
	$(CRYSTAL_BIN) build --release $(CURDIR)/src/prax.cr -o $(BINDIR)/prax-binary
	#strip --strip-uneeded $(BINDIR)/prax-binary

run: all
	./bin/prax-binary

ext:
	cd ext && make

install: ext release
	mkdir -p $(LIBDIR) $(PRAXDIR) $(USRBINDIR) $(BINDIR) $(DOCDIR) #$(GNOME_AUTOSTART)
	cp bin/prax $(BINDIR)
	cp -r libexec $(PRAXDIR)
	cp ext/libnss_prax.so.2 $(LIBDIR)
	cd $(USRBINDIR) && ln -sf ../../opt/prax/bin/prax
	cp README.md LICENSE install/prax.desktop $(DOCDIR)
	#cp install/prax.desktop $(GNOME_AUTOSTART)
	chmod -R 0755 $(PRAXDIR)/bin $(PRAXDIR)/libexec $(LIBDIR)/libnss_prax.so.2
	mkdir -p $(PREFIX)/etc/NetworkManager/dnsmasq.d $(PREFIX)/etc/dnsmasq.d
	cp install/dnsmasq $(PREFIX)/etc/NetworkManager/dnsmasq.d/prax
	cp install/dnsmasq $(PREFIX)/etc/dnsmasq.d/prax

package: install
	cd dist && fpm -s dir -t $(TARGET) \
		--name "prax" \
		--version "$(VERSION)" \
		$(DEPENDENCIES) \
		--maintainer "julien@portalier.com" \
		--url "https://github.com/ysbaddaden/prax.cr" \
		--description "Rack proxy server for development" \
		--vendor "" \
		--license "CeCILL 2.1 License" \
		--category devel \
		--after-install "$(INSTALL)/postinst" \
		--before-remove "$(INSTALL)/prerm" \
		--after-remove "$(INSTALL)/postrm" \
		etc lib opt usr

deb:
	mkdir -p $(INITD)
	cp $(CURDIR)/install/debian/initd $(INITD)/prax
	chmod -R 0755 $(INITD)/prax
	TARGET=deb DEPENDENCIES=$(DEB_DEPENDENCIES) INSTALL="../install/debian" make package
	mkdir -p packages
	mv dist/*.deb packages

.PHONY: test
test: all
	bundle exec rake test

.PHONY: clean
clean:
	rm -rf .crystal bin/prax-binary dist test/hosts/_logs
	cd ext && make clean
