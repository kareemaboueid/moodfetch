# Installation paths
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SHAREDIR ?= $(PREFIX)/share/moodfetch
CONFDIR ?= /etc/moodfetch

# Source directories
SRCDIR := $(shell pwd)
COREDIR := $(SRCDIR)/src/core
METRICSDIR := $(SRCDIR)/src/metrics
ASSETSDIR := $(SRCDIR)/assets
CONFIGDIR := $(SRCDIR)/config

# Verify Linux environment
check_linux:
	@if [ "$$(uname -s)" != "Linux" ]; then \
		echo "Error: This version only supports Linux"; \
		exit 1; \
	fi

install: check_linux
	@echo "Installing moodfetch..."
	@install -d "$(DESTDIR)$(BINDIR)"
	@install -d "$(DESTDIR)$(SHAREDIR)"
	@install -d "$(DESTDIR)$(SHAREDIR)/core"
	@install -d "$(DESTDIR)$(SHAREDIR)/metrics"
	@install -d "$(DESTDIR)$(CONFDIR)"
	
	# Install main executable
	@install -m 0755 "$(SRCDIR)/moodfetch" "$(DESTDIR)$(BINDIR)/moodfetch"
	
	# Install core modules
	@install -m 0644 "$(COREDIR)"/*.sh "$(DESTDIR)$(SHAREDIR)/core/"
	
	# Install metrics modules
	@install -m 0644 "$(METRICSDIR)"/*.sh "$(DESTDIR)$(SHAREDIR)/metrics/"
	
	# Install assets
	@install -m 0644 "$(ASSETSDIR)/ascii-art.txt" "$(DESTDIR)$(SHAREDIR)/"
	
	# Install configuration
	@install -m 0644 "$(CONFIGDIR)/config.example" "$(DESTDIR)$(CONFDIR)/config.example"
	
	@echo "Installation complete. Edit $(DESTDIR)$(CONFDIR)/config.example to create your configuration."
	@echo "Installed moodfetch to $(DESTDIR)$(BINDIR)/moodfetch"
	@echo "Support files installed to $(DESTDIR)$(SHAREDIR)"
	@echo "Example config installed to $(DESTDIR)/etc/moodfetch/config.example"

uninstall:
	@rm -f "$(DESTDIR)$(BINDIR)/moodfetch"
	@rm -rf "$(DESTDIR)$(SHAREDIR)"
	@echo "Removed moodfetch and its support files"

.PHONY: install uninstall
