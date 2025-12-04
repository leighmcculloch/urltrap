APP_NAME := URLCap
APP_BUNDLE := build/$(APP_NAME).app

.PHONY: all clean

all: $(APP_BUNDLE)

$(APP_BUNDLE): URLCap.applescript Info.plist url-handler-helper.swift
	rm -rf build
	mkdir -p build
	osacompile -o $(APP_BUNDLE) URLCap.applescript
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	swiftc -o $(APP_BUNDLE)/Contents/Resources/url-handler-helper url-handler-helper.swift -framework CoreServices 2>/dev/null || true
	@echo ""
	@echo "Build complete: $(APP_BUNDLE)"
	@echo ""
	@echo "To run: open $(APP_BUNDLE)"

clean:
	rm -rf build
