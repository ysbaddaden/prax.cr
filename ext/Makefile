CC=gcc
CFLAGS=-O2
OBJ=nss_prax.o

%.o: %.c
	$(CC) -Wall -fPIC -c -o $@ $< $(CFLAGS)

libnss_prax.so.2: $(OBJ)
	$(CC) -shared -o $@ $^ -Wl,-soname,libnss_prax.so.2 $(CFLAGS)

clean:
	rm -f *.o *~ libnss_prax.so.2

install: libnss_prax.so.2
	cp $(CURDIR)/libnss_prax.so.2 $(PREFIX)/lib
	sed -i -r -e '/\bprax\b/ !s/^hosts:(.+)\bdns\b/hosts:\1prax dns/' /etc/nsswitch.conf

uninstall:
	rm $(PREFIX)/lib/libnss_prax.so.2
	sed -i 's/ prax//' /etc/nsswitch.conf
