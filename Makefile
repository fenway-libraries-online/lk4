.PHONY: build install clean dist distclean

PROG = lk4
VERSION = 0.01

SOURCES = Makefile README LICENSE lk4.fcgi bin conf doc lib

PREFIX = /usr/local

INSTALL_PERL_LIB = $(PREFIX)/lib/site_perl
INSTALL_LK4	     = $(PREFIX)/lk4

build:

install: install-perl-lib install-perl-doc install-conf install-data install-bin install-doc

install-perl-lib: lib/Lk4.pm
	mkdir -p $(INSTALL_PERL_LIB)/
	cp -p $< $(INSTALL_PERL_LIB)/

install-perl-doc: lib/Lk4.pod
	mkdir -p $(INSTALL_PERL_LIB)/
	cp -p $< $(INSTALL_PERL_LIB)/

install-conf: conf
	mkdir -p $(INSTALL_LK4)/conf
	cp -p -R $< $(INSTALL_LK4)/

install-data: data
	mkdir -p $(INSTALL_LK4)/data
	cp -p -R $< $(INSTALL_LK4)/

install-bin: bin
	mkdir -p $(INSTALL_LK4)/bin
	cp -p -R $< $(INSTALL_LK4)/

install-doc: doc
	mkdir -p $(INSTALL_LK4)/doc
	cp -p -R $< $(INSTALL_LK4)/

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
