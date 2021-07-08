# sneedium - simple browser
# See LICENSE file for copyright and license details.
.POSIX:
VERSION = 2.1

PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
LIBPREFIX = $(PREFIX)/lib
LIBDIR = $(LIBPREFIX)/sneedium

X11INC = `pkg-config --cflags x11`
X11LIB = `pkg-config --libs x11`
GTKINC = `pkg-config --cflags gtk+-3.0 gcr-3 webkit2gtk-4.0`
GTKLIB = `pkg-config --libs gtk+-3.0 gcr-3 webkit2gtk-4.0`

INCS = $(X11INC) $(GTKINC) -Iinclude
LIBS = $(X11LIB) $(GTKLIB) -lgthread-2.0

CFLAGS = -Wall -Wextra -O2
CPPFLAGS = -DVERSION=\"$(VERSION)\" -DGCR_API_SUBJECT_TO_CHANGE \
           -DLIBPREFIX=\"$(LIBPREFIX)\" -D_DEFAULT_SOURCE

build/sneedium: build/sneedium.o
	$(CC) $(LDFLAGS) -o $@ build/sneedium.o $(LIBS)

build/sneedium.o: build include/config.h
	$(CC) -fPIC $(INCS) $(CPPFLAGS) $(CFLAGS) \
          -c src/sneedium.c -o build/sneedium.o

build:
	mkdir -p build

include/config.h:
	cp include/config.def.h include/config.h

.PHONY: all clean  distclean dist install uninstall
all: build/sneedium

clean:
	rm -rf build

distclean: clean
	rm -f include/config.h sneedium-$(VERSION).tar.gz

dist: distclean
	mkdir -p sneedium-$(VERSION)
	cp -R * sneedium-$(VERSION)
	tar -cf sneedium-$(VERSION).tar sneedium-$(VERSION)
	gzip sneedium-$(VERSION).tar
	rm -rf sneedium-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f sneedium $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/sneedium
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/$(VERSION)/g" < man/sneedium.1 > \
         $(DESTDIR)$(MANPREFIX)/man1/sneedium.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/sneedium.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/sneedium
	rm -f $(DESTDIR)$(MANPREFIX)/man1/sneedium.1
