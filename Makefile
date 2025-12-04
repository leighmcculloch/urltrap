APP_NAME := URLCap
APP_BUNDLE := build/$(APP_NAME).app

.PHONY: all clean

all: $(APP_BUNDLE)

$(APP_BUNDLE): main.swift Info.plist
	rm -rf build
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	swiftc -o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) main.swift -framework Cocoa -framework CoreServices
	codesign --force --deep --sign - $(APP_BUNDLE)
	@echo ""
	@echo "Build complete: $(APP_BUNDLE)"
	@echo ""
	@echo "To run: open $(APP_BUNDLE)"

clean:
	rm -rf build
