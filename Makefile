SCHEMES ?= http,https
SORTED_SCHEMES := $(shell echo "$(SCHEMES)" | tr ',' '\n' | sort | tr '\n' ',' | sed 's/,$$//')
APP_NAME := URLTrap ($(SORTED_SCHEMES))
APP_BUNDLE := build/$(APP_NAME).app

.PHONY: build clean install

install: build
	@if [ -e ~/Applications/"$(APP_NAME).app" ]; then \
		rm -ri ~/Applications/"$(APP_NAME).app" || exit 1; \
	fi
	cp -R "$(APP_BUNDLE)" ~/Applications/
	@echo "Installed to ~/Applications/$(APP_NAME).app"

build: clean main.swift Info.plist
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	swiftc -o "$(APP_BUNDLE)/Contents/MacOS/URLTrap" main.swift -framework Cocoa
	cp Info.plist "$(APP_BUNDLE)/Contents/Info.plist"
	@echo "Adding schemes: $(SORTED_SCHEMES)"
	@/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$(APP_BUNDLE)/Contents/Info.plist"
	@i=0; for scheme in $$(echo "$(SORTED_SCHEMES)" | tr ',' ' '); do \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i dict" "$(APP_BUNDLE)/Contents/Info.plist"; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i:CFBundleURLName string '$$scheme URL'" "$(APP_BUNDLE)/Contents/Info.plist"; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i:CFBundleURLSchemes array" "$(APP_BUNDLE)/Contents/Info.plist"; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i:CFBundleURLSchemes:0 string '$$scheme'" "$(APP_BUNDLE)/Contents/Info.plist"; \
		i=$$((i + 1)); \
	done
	codesign --force --deep --sign - "$(APP_BUNDLE)"
	@echo ""
	@echo "Build complete: $(APP_BUNDLE)"
	@echo "Schemes: $(SORTED_SCHEMES)"
	@echo ""
	@echo "To run: open \"$(APP_BUNDLE)\""

clean:
	rm -rf build
