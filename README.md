<h1 align="center"><img src="icon-rounded.png" width="200" /></h1>

A macOS application that intercepts URL scheme opens, captures the URLs, and displays them. When the app quits, it restores the original handlers.

## Install

```bash
make install
```

Installs to `~/Applications/URLTrap (http,https).app`.

Or with custom schemes:

```bash
make install SCHEMES=ftp,mailto
```

Installs to `~/Applications/URLTrap (ftp,mailto).app`.

## Build

```bash
make build
```

Builds to `./build/URLTrap (http,https).app`.

Or with custom schemes:

```bash
make build SCHEMES=ftp,mailto
```

Builds to `./build/URLTrap (ftp,mailto).app`.

## Usage

1. Launch URLTrap by double clicking the .app file.
2. The app registers itself as the handler for the configured URL schemes
3. Any URL opens for those schemes will be captured and displayed
4. Quit the app and original original handlers will be restored

## Requirements

- macOS 10.15+
- Xcode Command Line Tools (for `swiftc` and `codesign`)
