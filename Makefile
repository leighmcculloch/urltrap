SCHEMES ?= http,https
SORTED_SCHEMES := $(shell echo "$(SCHEMES)" | tr ',' '\n' | sort | tr '\n' ',' | sed 's/,$$//')
APP_NAME := URLTrap ($(SORTED_SCHEMES))
APP_BUNDLE := build/$(APP_NAME).app

.PHONY: build clean install icon-rounded

install: build
	@if [ -e ~/Applications/"$(APP_NAME).app" ]; then \
		rm -ri ~/Applications/"$(APP_NAME).app" || exit 1; \
	fi
	cp -R "$(APP_BUNDLE)" ~/Applications/"$(APP_NAME).app"
	@echo "Installed to ~/Applications/$(APP_NAME).app"

build: clean main.swift Info.plist icon.png
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	swiftc -o "$(APP_BUNDLE)/Contents/MacOS/URLTrap" main.swift -framework Cocoa
	cp Info.plist "$(APP_BUNDLE)/Contents/Info.plist"
	mkdir -p build/icon.iconset
	sips -z 16 16 icon.png --out build/icon.iconset/icon_16x16.png
	sips -z 32 32 icon.png --out build/icon.iconset/icon_16x16@2x.png
	sips -z 32 32 icon.png --out build/icon.iconset/icon_32x32.png
	sips -z 64 64 icon.png --out build/icon.iconset/icon_32x32@2x.png
	sips -z 128 128 icon.png --out build/icon.iconset/icon_128x128.png
	sips -z 256 256 icon.png --out build/icon.iconset/icon_128x128@2x.png
	sips -z 256 256 icon.png --out build/icon.iconset/icon_256x256.png
	sips -z 512 512 icon.png --out build/icon.iconset/icon_256x256@2x.png
	sips -z 512 512 icon.png --out build/icon.iconset/icon_512x512.png
	sips -z 1024 1024 icon.png --out build/icon.iconset/icon_512x512@2x.png
	iconutil -c icns build/icon.iconset -o "$(APP_BUNDLE)/Contents/Resources/AppIcon.icns"
	rm -rf build/icon.iconset
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

icon-rounded: icon.png round-icon.swift
	swiftc -o build/round-icon round-icon.swift -framework Cocoa
	./build/round-icon icon.png icon-rounded.png 256
	@echo "Created icon-rounded.png"
