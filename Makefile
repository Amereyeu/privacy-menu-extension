SHELL = bash
UUID = PrivacyMenu@stuarthayhurst
COMPRESSLEVEL = -o7

.PHONY: build check release translations gtk4 prune compress install uninstall clean

build: clean
	glib-compile-schemas schemas
	gnome-extensions pack --force --podir=po --extra-source=LICENSE.txt --extra-source=docs/CHANGELOG.md --extra-source=icons/ --extra-source=ui --extra-source=lib/
check:
	@if [[ ! -f "$(UUID).shell-extension.zip" ]]; then \
	  echo -e "WARNING! Extension zip couldn't be found"; exit 1; \
	elif [[ "$$(stat -c %s $(UUID).shell-extension.zip)" -gt 4096000 ]]; then \
	  echo -e "\nWARNING! The extension is too big to be uploaded to the extensions website, keep it smaller than 4096 KB"; exit 1; \
	fi
release:
	@if [[ "$(VERSION)" != "" ]]; then \
	  sed -i "s|  \"version\":.*|  \"version\": $(VERSION)|g" metadata.json; \
	fi
	#Call other targets required to make a release
	$(MAKE) gtk4
	$(MAKE) translations prune compress
	$(MAKE) build
	$(MAKE) check
translations:
	./scripts/update-pot.sh
	./scripts/update-po.sh -a
gtk4:
	gtk4-builder-tool simplify --3to4 ui/prefs.ui > ui/prefs-gtk4.ui
prune:
	./scripts/clean-svgs.py
compress:
	optipng "$(COMPRESSLEVEL)" -strip all docs/*.png
install:
	gnome-extensions install "$(UUID).shell-extension.zip" --force
uninstall:
	gnome-extensions uninstall "$(UUID)"
clean:
	@rm -rfv locale schemas/gschemas.compiled "$(UUID).shell-extension.zip"
	@rm -rfv po/*.po~ *.ui~ ui/*.ui~ ui/*.ui#
