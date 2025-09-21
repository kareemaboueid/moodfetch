PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SHAREDIR ?= $(PREFIX)/share/moodfetch
SRCDIR := $(shell pwd)

install:
	@install -d "$(DESTDIR)$(BINDIR)"
	@install -d "$(DESTDIR)$(SHAREDIR)"
	@install -m 0755 "$(SRCDIR)/moodfetch" "$(DESTDIR)$(BINDIR)/moodfetch"
	@install -m 0644 "$(SRCDIR)"/*.sh "$(DESTDIR)$(SHAREDIR)/"
	@install -m 0644 "$(SRCDIR)/ascii-art.txt" "$(DESTDIR)$(SHAREDIR)/"
	@echo "Installed moodfetch to $(DESTDIR)$(BINDIR)/moodfetch"
	@echo "Support files installed to $(DESTDIR)$(SHAREDIR)"

uninstall:
	@rm -f "$(DESTDIR)$(BINDIR)/moodfetch"
	@rm -rf "$(DESTDIR)$(SHAREDIR)"
	@echo "Removed moodfetch and its support files"

.PHONY: install uninstall
