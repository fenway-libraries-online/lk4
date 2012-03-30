.PHONY: build install clean dist distclean

PROG = l4x
VERSION = 0.01

SOURCES = Makefile README LICENSE l4x.fcgi bin conf doc lib

PREFIX = /usr/local

INSTALL_PERL_LIB = $(PREFIX)/lib/site_perl
INSTALL_ROOT	 = $(PREFIX)/l4x

build:

install: install-perl-lib install-conf install-data install-bin install-doc

install-perl-lib: lib/L4x.pm
	mkdir -p $(INSTALL_PERL_LIB)/
	cp -p $< $(INSTALL_PERL_LIB)/

install-conf: conf
	mkdir -p $(INSTALL_ROOT)/conf
	cp -p -R $< $(INSTALL_ROOT)/

install-data: data
	mkdir -p $(INSTALL_ROOT)/data
	cp -p -R $< $(INSTALL_ROOT)/

install-bin: bin
	mkdir -p $(INSTALL_ROOT)/bin
	cp -p -R $< $(INSTALL_ROOT)/

install-doc: doc
	mkdir -p $(INSTALL_ROOT)/doc
	cp -p -R $< $(INSTALL_ROOT)/

clean:

# --- Distribution targets

dist: $(PROG)-$(VERSION).tar.gz

$(PROG)-$(VERSION).tar.gz: $(PROG)-$(VERSION)
	tar -czf $@ $<

$(PROG)-$(VERSION):
	mkdir -p $@
	cp -r $(SOURCES) $@/

distclean:
	rm -f  $(PROG)-$(VERSION).tar.gz
	rm -Rf $(PROG)-$(VERSION)
