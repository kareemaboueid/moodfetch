PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SHAREDIR ?= $(PREFIX)/share/moodfetch
THEMEDIR ?= $(SHAREDIR)/themes
SRCDIR := $(shell pwd)

install:
	@install -d "$(DESTDIR)$(BINDIR)"
	@install -d "$(DESTDIR)$(SHAREDIR)"
	@install -d "$(DESTDIR)$(THEMEDIR)"
	@install -d "$(DESTDIR)/etc/moodfetch"
	@install -m 0755 "$(SRCDIR)/moodfetch" "$(DESTDIR)$(BINDIR)/moodfetch"
	@install -m 0644 "$(SRCDIR)"/*.sh "$(DESTDIR)$(SHAREDIR)/"
	@install -m 0644 "$(SRCDIR)/ascii-art.txt" "$(DESTDIR)$(SHAREDIR)/"
	@install -m 0644 "$(SRCDIR)/config.example" "$(DESTDIR)/etc/moodfetch/config.example"
	@install -m 0644 "$(SRCDIR)/themes"/*.theme "$(DESTDIR)$(THEMEDIR)/"
	@echo "Installed moodfetch to $(DESTDIR)$(BINDIR)/moodfetch"
	@echo "Support files installed to $(DESTDIR)$(SHAREDIR)"
	@echo "Example config installed to $(DESTDIR)/etc/moodfetch/config.example"

uninstall:
	@rm -f "$(DESTDIR)$(BINDIR)/moodfetch"
	@rm -rf "$(DESTDIR)$(SHAREDIR)"
	@echo "Removed moodfetch and its support files"

.PHONY: install uninstall
