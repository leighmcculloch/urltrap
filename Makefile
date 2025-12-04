APP_NAME := URLTrap
APP_BUNDLE := build/$(APP_NAME).app
SCHEMES ?= http,https

.PHONY: all clean

all: $(APP_BUNDLE)

$(APP_BUNDLE): main.swift Info.plist.template
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	@echo "Generating Info.plist for schemes: $(SCHEMES)"
	@( \
		schemes="$(SCHEMES)"; \
		entries=""; \
		IFS=','; \
		for scheme in $$schemes; do \
			entries="$$entries        <dict>\n"; \
			entries="$$entries            <key>CFBundleURLName</key>\n"; \
			entries="$$entries            <string>$$scheme URL</string>\n"; \
			entries="$$entries            <key>CFBundleURLSchemes</key>\n"; \
			entries="$$entries            <array>\n"; \
			entries="$$entries                <string>$$scheme</string>\n"; \
			entries="$$entries            </array>\n"; \
			entries="$$entries        </dict>\n"; \
		done; \
		sed "s|@@SCHEME_ENTRIES@@|$$entries|" Info.plist.template \
	) > $(APP_BUNDLE)/Contents/Info.plist
	swiftc -o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) main.swift -framework Cocoa
	codesign --force --deep --sign - $(APP_BUNDLE)
	@echo ""
	@echo "Build complete: $(APP_BUNDLE)"
	@echo "Schemes: $(SCHEMES)"
	@echo ""
	@echo "To run: open $(APP_BUNDLE)"

clean:
	rm -rf build
