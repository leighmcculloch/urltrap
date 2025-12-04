import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var originalHttpHandler: String?
    var originalHttpsHandler: String?
    var capturedURLs: [String] = []
    var window: NSWindow?
    var textView: NSTextView?
    let bundleID = Bundle.main.bundleIdentifier ?? "com.urlcap.URLCap"

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Save original handlers
        originalHttpHandler = getCurrentHandler(scheme: "http")
        originalHttpsHandler = getCurrentHandler(scheme: "https")

        // Register as handler
        setHandler(scheme: "http", bundleID: bundleID)
        setHandler(scheme: "https", bundleID: bundleID)

        // Give the system a moment to process, then check if registration worked
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let currentHandler = getCurrentHandler(scheme: "http")
            if currentHandler != bundleID {
                let alert = NSAlert()
                alert.messageText = "Registration Required"
                alert.informativeText = "Please click 'Use URLCap' in the system dialog to enable URL capture, then reopen this app."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                NSApp.terminate(nil)
            }
        }

        setupWindow()
        updateDisplay()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            capturedURLs.append(url.absoluteString)
        }
        updateDisplay()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Restore original handlers
        if let handler = originalHttpHandler {
            setHandler(scheme: "http", bundleID: handler)
        }
        if let handler = originalHttpsHandler {
            setHandler(scheme: "https", bundleID: handler)
        }
    }

    func setupWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 500, height: 400)
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window?.title = "URLCap - URL Capture"
        window?.center()

        let contentView = NSView(frame: windowRect)

        // Text view with scroll
        let scrollView = NSScrollView(frame: NSRect(x: 20, y: 60, width: 460, height: 320))
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .bezelBorder

        textView = NSTextView(frame: scrollView.bounds)
        textView?.autoresizingMask = [.width, .height]
        textView?.isEditable = false
        textView?.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        scrollView.documentView = textView

        contentView.addSubview(scrollView)

        // Clear button
        let clearButton = NSButton(frame: NSRect(x: 20, y: 15, width: 100, height: 30))
        clearButton.title = "Clear"
        clearButton.bezelStyle = .rounded
        clearButton.target = self
        clearButton.action = #selector(clearURLs)
        clearButton.autoresizingMask = [.maxXMargin, .maxYMargin]
        contentView.addSubview(clearButton)

        // Quit button
        let quitButton = NSButton(frame: NSRect(x: 380, y: 15, width: 100, height: 30))
        quitButton.title = "Quit"
        quitButton.bezelStyle = .rounded
        quitButton.target = self
        quitButton.action = #selector(quitApp)
        quitButton.autoresizingMask = [.minXMargin, .maxYMargin]
        contentView.addSubview(quitButton)

        window?.contentView = contentView
        window?.makeKeyAndOrderFront(nil)
    }

    func updateDisplay() {
        var text = "URLCap is active and capturing HTTP/HTTPS URLs.\n\n"
        text += "Original HTTP handler: \(originalHttpHandler ?? "unknown")\n"
        text += "Original HTTPS handler: \(originalHttpsHandler ?? "unknown")\n\n"
        text += "Captured URLs:\n"

        if capturedURLs.isEmpty {
            text += "(No URLs captured yet)\n"
        } else {
            for (i, url) in capturedURLs.enumerated() {
                text += "\(i + 1). \(url)\n"
            }
        }

        text += "\nClick 'Quit' to stop capturing and restore original handlers."
        textView?.string = text
    }

    @objc func clearURLs() {
        capturedURLs = []
        updateDisplay()
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func getCurrentHandler(scheme: String) -> String? {
        guard let url = URL(string: "\(scheme)://example.com") else { return nil }
        guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: url) else { return nil }
        guard let bundle = Bundle(url: appURL) else { return nil }
        return bundle.bundleIdentifier
    }

    func setHandler(scheme: String, bundleID: String) {
        NSWorkspace.shared.setDefaultApplication(
            at: NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)!,
            toOpenURLsWithScheme: scheme
        ) { error in
            if let error = error {
                print("Failed to set handler: \(error)")
            }
        }
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
