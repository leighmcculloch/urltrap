import Foundation
import CoreServices

func getCurrentHandler(scheme: String) -> String? {
    if let result = LSCopyDefaultHandlerForURLScheme(scheme as CFString) {
        return result.takeRetainedValue() as String
    }
    return nil
}

func setHandler(scheme: String, bundleID: String) -> Bool {
    let result = LSSetDefaultHandlerForURLScheme(scheme as CFString, bundleID as CFString)
    return result == 0
}

func main() {
    let args = CommandLine.arguments

    guard args.count >= 2 else {
        print("Usage:")
        print("  \(args[0]) get <scheme>        - Get current handler for scheme")
        print("  \(args[0]) set <scheme> <id>   - Set handler for scheme to bundle ID")
        print("")
        print("Examples:")
        print("  \(args[0]) get http")
        print("  \(args[0]) set http com.apple.Safari")
        exit(1)
    }

    let command = args[1]

    switch command {
    case "get":
        guard args.count >= 3 else {
            fputs("Error: Missing scheme argument\n", stderr)
            exit(1)
        }
        let scheme = args[2]
        if let handler = getCurrentHandler(scheme: scheme) {
            print(handler)
        } else {
            fputs("Error: Could not get handler for \(scheme)\n", stderr)
            exit(1)
        }

    case "set":
        guard args.count >= 4 else {
            fputs("Error: Missing scheme or bundle ID argument\n", stderr)
            exit(1)
        }
        let scheme = args[2]
        let bundleID = args[3]
        if setHandler(scheme: scheme, bundleID: bundleID) {
            print("OK")
        } else {
            fputs("Error: Failed to set handler for \(scheme) to \(bundleID)\n", stderr)
            exit(1)
        }

    default:
        fputs("Error: Unknown command '\(command)'\n", stderr)
        exit(1)
    }
}

main()
