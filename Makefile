# sneedium - simple browser
# See LICENSE file for copyright and license details.
.POSIX:

include config.mk

SRC = sneedium.c
WSRC = webext-sneedium.c
OBJ = $(SRC:.c=.o)
WOBJ = $(WSRC:.c=.o)
WLIB = $(WSRC:.c=.so)

all: options sneedium $(WLIB)

options:
	@echo sneedium build options:
	@echo "CC            = $(CC)"
	@echo "CFLAGS        = $(SNEEDIUMCFLAGS) $(CFLAGS)"
	@echo "WEBEXTCFLAGS  = $(WEBEXTCFLAGS) $(CFLAGS)"
	@echo "LDFLAGS       = $(LDFLAGS)"

sneedium: $(OBJ)
	$(CC) $(SNEEDIUMLDFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

$(OBJ) $(WOBJ): config.h common.h config.mk

config.h:
	cp config.def.h $@

$(OBJ): $(SRC)
	$(CC) $(SNEEDIUMCFLAGS) $(CFLAGS) -c $(SRC)

$(WLIB): $(WOBJ)
	$(CC) -shared -Wl,-soname,$@ $(LDFLAGS) -o $@ $? $(WEBEXTLIBS)

$(WOBJ): $(WSRC)
	$(CC) $(WEBEXTCFLAGS) $(CFLAGS) -c $(WSRC)

clean:
	rm -f sneedium $(OBJ)
	rm -f $(WLIB) $(WOBJ)

distclean: clean
	rm -f config.h sneedium-$(VERSION).tar.gz

dist: distclean
	mkdir -p sneedium-$(VERSION)
	cp -R LICENSE Makefile config.mk config.def.h README \
	    sneedium-open.sh arg.h TODO.md sneedium.png \
	    sneedium.1 common.h $(SRC) $(WSRC) sneedium-$(VERSION)
	tar -cf sneedium-$(VERSION).tar sneedium-$(VERSION)
	gzip sneedium-$(VERSION).tar
	rm -rf sneedium-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f sneedium $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/sneedium
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp -f $(WLIB) $(DESTDIR)$(LIBDIR)
	for wlib in $(WLIB); do \
	    chmod 644 $(DESTDIR)$(LIBDIR)/$$wlib; \
	done
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/$(VERSION)/g" < sneedium.1 > $(DESTDIR)$(MANPREFIX)/man1/sneedium.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/sneedium.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/sneedium
	rm -f $(DESTDIR)$(MANPREFIX)/man1/sneedium.1
	for wlib in $(WLIB); do \
	    rm -f $(DESTDIR)$(LIBDIR)/$$wlib; \
	done
	- rmdir $(DESTDIR)$(LIBDIR)

.PHONY: all options distclean clean dist install uninstall
