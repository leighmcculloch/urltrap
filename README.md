# URLTrap

A macOS application that intercepts URL scheme opens, captures the URLs, and displays them. When the app quits, it restores the original handlers.

## Build

```bash
make
```

To build with custom URL schemes:

```bash
make SCHEMES=http,https,ftp,mailto
```

Default schemes are `http,https`.

## Run

```bash
open build/URLTrap.app
```

## Usage

1. Launch URLTrap
2. The app registers itself as the handler for the configured URL schemes
3. Any URL opens for those schemes will be captured and displayed
4. Click "Clear" to clear captured URLs
5. Click "Quit" to exit and restore original handlers

## Requirements

- macOS 10.15+
- Xcode Command Line Tools (for `swiftc` and `codesign`)
