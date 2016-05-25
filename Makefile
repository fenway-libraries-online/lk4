include config.mk

VERSION = 0.11
SOURCES = Makefile DEPENDENCIES LICENSE README VERSION configure bin cgi-bin conf data doc lib service

build: $(SOURCES) lib
	mkdir -p build
	cp -r $(SOURCES) build/
	if [ "$(WWW_LK4_VERSION)" != installed ]; then \
	    cp -r embedded/WWW-Lk4-$(WWW_LK4_VERSION)/lib build/lib/perl5lib; \
	    perl -i -pe 's{/usr/local/lk4}{$(INSTALL_LK4)}' build/*bin/*; \
	fi

install: install-cgi-bin install-conf install-data install-bin install-doc install-lib

install-cgi-bin: build/cgi-bin
	mkdir -p $(INSTALL_LK4)/cgi-bin
	cp -p -R $< $(INSTALL_LK4)/

install-conf: build/conf
	mkdir -p $(INSTALL_LK4)/conf
	cp -p -R $< $(INSTALL_LK4)/

install-data: build/data
	mkdir -p $(INSTALL_LK4)/data
	cp -p -R $< $(INSTALL_LK4)/

install-bin: build/bin
	mkdir -p $(INSTALL_LK4)/bin
	cp -p -R $< $(INSTALL_LK4)/

install-doc: build/doc
	mkdir -p $(INSTALL_LK4)/doc
	cp -p -R $< $(INSTALL_LK4)/

install-lib: build/lib
	mkdir -p $(INSTALL_LK4)/lib
	cp -p -R $< $(INSTALL_LK4)/

clean:
	rm -Rf build

# --- Distribution targets

dist: VERSION $(PROG)-$(VERSION).tar.gz

VERSION: Makefile
	@echo "This is lk4 version $(VERSION)." > $@

$(PROG)-$(VERSION).tar.gz: $(PROG)-$(VERSION)
	tar -czf $@ $<

$(PROG)-$(VERSION):
	mkdir -p $@
	cp -r $(SOURCES) embedded $@/

distclean:
	rm -f  $(PROG)-$(VERSION).tar.gz
	rm -Rf $(PROG)-$(VERSION)

.PHONY: build install clean dist distclean
