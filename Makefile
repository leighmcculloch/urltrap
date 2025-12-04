APP_NAME := URLTrap
APP_BUNDLE := build/$(APP_NAME).app
SCHEMES ?= http,https

.PHONY: all clean

all: $(APP_BUNDLE)

$(APP_BUNDLE): main.swift Info.plist
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	swiftc -o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) main.swift -framework Cocoa
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	@echo "Adding schemes: $(SCHEMES)"
	@/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" $(APP_BUNDLE)/Contents/Info.plist
	@i=0; for scheme in $$(echo "$(SCHEMES)" | tr ',' ' '); do \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i dict" $(APP_BUNDLE)/Contents/Info.plist; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i:CFBundleURLName string '$$scheme URL'" $(APP_BUNDLE)/Contents/Info.plist; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i:CFBundleURLSchemes array" $(APP_BUNDLE)/Contents/Info.plist; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$$i:CFBundleURLSchemes:0 string '$$scheme'" $(APP_BUNDLE)/Contents/Info.plist; \
		i=$$((i + 1)); \
	done
	codesign --force --deep --sign - $(APP_BUNDLE)
	@echo ""
	@echo "Build complete: $(APP_BUNDLE)"
	@echo "Schemes: $(SCHEMES)"
	@echo ""
	@echo "To run: open $(APP_BUNDLE)"

clean:
	rm -rf build
