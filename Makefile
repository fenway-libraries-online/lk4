.PHONY: build install clean dist distclean

PROG = lk4
VERSION = 0.03

SOURCES = Makefile README LICENSE bin cgi-bin conf data doc lib service

PREFIX = /usr/local

INSTALL_LK4	= $(PREFIX)/lk4

build:

install: install-lib install-cgi-bin install-conf install-data install-bin install-doc

install-lib: lib
	mkdir -p $(INSTALL_LK4)/lib
	cp -p -R $< $(INSTALL_LK4)/

install-cgi-bin: cgi-bin
	mkdir -p $(INSTALL_LK4)/cgi-bin
	cp -p -R $< $(INSTALL_LK4)/

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

dist: VERSION $(PROG)-$(VERSION).tar.gz

VERSION: Makefile
	@echo "This is lk4 version $(VERSION)." > $@

$(PROG)-$(VERSION).tar.gz: $(PROG)-$(VERSION)
	tar -czf $@ $<

$(PROG)-$(VERSION):
	mkdir -p $@
	cp -r $(SOURCES) $@/

distclean:
	rm -f  $(PROG)-$(VERSION).tar.gz
	rm -Rf $(PROG)-$(VERSION)

