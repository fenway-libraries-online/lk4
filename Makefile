.PHONY: build install clean dist distclean

PROG = l4x
VERSION = 0.01

SOURCES = Makefile README LICENSE l4x.fcgi bin conf doc lib

PREFIX = /usr/local

INSTALL_PERL_LIB = $(PREFIX)/lib/site_perl
INSTALL_L4X	     = $(PREFIX)/l4x

build:

install: install-perl-lib install-perl-doc install-conf install-data install-bin install-doc

install-perl-lib: lib/L4x.pm
	mkdir -p $(INSTALL_PERL_LIB)/
	cp -p $< $(INSTALL_PERL_LIB)/

install-perl-doc: lib/L4x.pod
	mkdir -p $(INSTALL_PERL_LIB)/
	cp -p $< $(INSTALL_PERL_LIB)/

install-conf: conf
	mkdir -p $(INSTALL_L4X)/conf
	cp -p -R $< $(INSTALL_L4X)/

install-data: data
	mkdir -p $(INSTALL_L4X)/data
	cp -p -R $< $(INSTALL_L4X)/

install-bin: bin
	mkdir -p $(INSTALL_L4X)/bin
	cp -p -R $< $(INSTALL_L4X)/

install-doc: doc
	mkdir -p $(INSTALL_L4X)/doc
	cp -p -R $< $(INSTALL_L4X)/

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
