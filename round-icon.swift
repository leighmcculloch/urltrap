import Cocoa

let args = CommandLine.arguments
guard args.count >= 3 else {
    print("Usage: round-icon <input.png> <output.png> [size]")
    exit(1)
}

let inputPath = args[1]
let outputPath = args[2]
let size = args.count >= 4 ? Int(args[3]) ?? 256 : 256

guard let inputImage = NSImage(contentsOfFile: inputPath) else {
    print("Error: Could not load \(inputPath)")
    exit(1)
}

let cgSize = CGFloat(size)
let padding = cgSize * 0.11
let outputSize = NSSize(width: size, height: size)
let iconSize = CGFloat(size) - padding * 2
let outputImage = NSImage(size: outputSize)

outputImage.lockFocus()

let iconRect = NSRect(x: padding, y: padding + cgSize * 0.015, width: iconSize, height: iconSize)
let radius = iconSize * 0.23 // macOS Big Sur style corner radius

// Create the rounded path for the icon
let path = NSBezierPath(roundedRect: iconRect, xRadius: radius, yRadius: radius)

// Draw shadow
NSGraphicsContext.current?.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.6)
shadow.shadowOffset = NSSize(width: 0, height: -cgSize * 0.02)
shadow.shadowBlurRadius = cgSize * 0.07
shadow.set()
NSColor.black.setFill()
path.fill()
NSGraphicsContext.current?.restoreGraphicsState()

// Clip to rounded rect and draw the image
NSGraphicsContext.current?.saveGraphicsState()
path.addClip()
inputImage.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: 1.0)
NSGraphicsContext.current?.restoreGraphicsState()

// Draw the border with highlights at top-left and bottom-right corners
let insetRect = iconRect.insetBy(dx: 0.5, dy: 0.5)

// Draw base subtle border
NSGraphicsContext.current?.saveGraphicsState()
let borderPath = NSBezierPath(roundedRect: insetRect, xRadius: radius, yRadius: radius)
NSColor.white.withAlphaComponent(0.05).setStroke()
borderPath.lineWidth = 0.5
borderPath.stroke()
NSGraphicsContext.current?.restoreGraphicsState()

// Helper to draw fading segments along a path
func drawFadingSegments(points: [(CGPoint, CGFloat)], lineWidth: CGFloat) {
    for i in 0..<(points.count - 1) {
        let start = points[i]
        let end = points[i + 1]
        let avgAlpha = (start.1 + end.1) / 2

        NSGraphicsContext.current?.saveGraphicsState()
        let segmentPath = NSBezierPath()
        segmentPath.move(to: start.0)
        segmentPath.line(to: end.0)
        NSColor.white.withAlphaComponent(avgAlpha).setStroke()
        segmentPath.lineWidth = lineWidth
        segmentPath.stroke()
        NSGraphicsContext.current?.restoreGraphicsState()
    }
}

// Top-left highlight: bright at corner, fading along left side and top edge
let topLeftCorner = NSPoint(x: insetRect.minX + radius * 0.3, y: insetRect.maxY - radius * 0.3)
let numSegments = 12

let maxAlpha: CGFloat = 0.45  // Maximum highlight brightness
let lineW: CGFloat = 2.5  // Line width for highlights

// Left side segments (from lower on left side up to corner)
var leftSidePoints: [(CGPoint, CGFloat)] = []
for i in 0...numSegments {
    let t = CGFloat(i) / CGFloat(numSegments)
    let startY = insetRect.minY + insetRect.height * 0.3  // Start lower (30% from bottom)
    let y = startY + t * (insetRect.maxY - radius - startY)
    let alpha: CGFloat = t * maxAlpha  // Fade in as we go up
    leftSidePoints.append((NSPoint(x: insetRect.minX, y: y), alpha))
}
drawFadingSegments(points: leftSidePoints, lineWidth: lineW)

// Top-left corner arc segments
var cornerPoints: [(CGPoint, CGFloat)] = []
for i in 0...numSegments {
    let angle = CGFloat.pi + CGFloat(i) / CGFloat(numSegments) * (CGFloat.pi / 2)
    let x = insetRect.minX + radius + radius * cos(angle)
    let y = insetRect.maxY - radius - radius * sin(angle)
    cornerPoints.append((NSPoint(x: x, y: y), maxAlpha))  // Full brightness at corner
}
drawFadingSegments(points: cornerPoints, lineWidth: lineW)

// Top edge segments (from corner to further right - 70% across)
var topEdgePoints: [(CGPoint, CGFloat)] = []
for i in 0...numSegments {
    let t = CGFloat(i) / CGFloat(numSegments)
    let endX = insetRect.minX + insetRect.width * 0.7  // End at 70% across
    let x = insetRect.minX + radius + t * (endX - insetRect.minX - radius)
    let alpha: CGFloat = maxAlpha * (1.0 - t)  // Fade out as we go right
    topEdgePoints.append((NSPoint(x: x, y: insetRect.maxY), alpha))
}
drawFadingSegments(points: topEdgePoints, lineWidth: lineW)

// Bottom-right highlight: bright at corner, fading along right side and bottom edge
// Right side segments (from higher on right side down to corner)
var rightSidePoints: [(CGPoint, CGFloat)] = []
for i in 0...numSegments {
    let t = CGFloat(i) / CGFloat(numSegments)
    let startY = insetRect.minY + insetRect.height * 0.7  // Start higher (70% from bottom)
    let y = startY - t * (startY - insetRect.minY - radius)
    let alpha: CGFloat = t * maxAlpha  // Fade in as we go down
    rightSidePoints.append((NSPoint(x: insetRect.maxX, y: y), alpha))
}
drawFadingSegments(points: rightSidePoints, lineWidth: lineW)

// Bottom-right corner arc segments
var brCornerPoints: [(CGPoint, CGFloat)] = []
for i in 0...numSegments {
    let angle = CGFloat(i) / CGFloat(numSegments) * (CGFloat.pi / 2)
    let x = insetRect.maxX - radius + radius * cos(angle)
    let y = insetRect.minY + radius - radius * sin(angle)
    brCornerPoints.append((NSPoint(x: x, y: y), maxAlpha))  // Full brightness at corner
}
drawFadingSegments(points: brCornerPoints, lineWidth: lineW)

// Bottom edge segments (from corner to further left - 30% from right)
var bottomEdgePoints: [(CGPoint, CGFloat)] = []
for i in 0...numSegments {
    let t = CGFloat(i) / CGFloat(numSegments)
    let endX = insetRect.minX + insetRect.width * 0.3  // End at 30% from left
    let x = insetRect.maxX - radius - t * (insetRect.maxX - radius - endX)
    let alpha: CGFloat = maxAlpha * (1.0 - t)  // Fade out as we go left
    bottomEdgePoints.append((NSPoint(x: x, y: insetRect.minY), alpha))
}
drawFadingSegments(points: bottomEdgePoints, lineWidth: lineW)

outputImage.unlockFocus()

guard let tiffData = outputImage.tiffRepresentation,
      let bitmapRep = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    print("Error: Could not create PNG")
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Created \(outputPath)")
} catch {
    print("Error: \(error)")
    exit(1)
}
