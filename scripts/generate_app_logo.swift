#!/usr/bin/env swift
import AppKit
import Foundation

let outputPath = CommandLine.arguments.dropFirst().first ?? "icon-1024.png"
let outputURL = URL(fileURLWithPath: outputPath)
let canvasSize: CGFloat = 1024
let image = NSImage(size: NSSize(width: canvasSize, height: canvasSize))

image.lockFocus()
guard let context = NSGraphicsContext.current?.cgContext else {
    fputs("Failed to create drawing context.\n", stderr)
    exit(1)
}
context.setShouldAntialias(true)
context.interpolationQuality = .high

let outerInset: CGFloat = 40
let outerRect = NSRect(
    x: outerInset,
    y: outerInset,
    width: canvasSize - outerInset * 2,
    height: canvasSize - outerInset * 2
)
let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: 220, yRadius: 220)

let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.16)
shadow.shadowOffset = NSSize(width: 0, height: -18)
shadow.shadowBlurRadius = 28
shadow.set()

let backgroundGradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.05, green: 0.18, blue: 0.40, alpha: 1.0),
    NSColor(calibratedRed: 0.08, green: 0.34, blue: 0.67, alpha: 1.0),
    NSColor(calibratedRed: 0.10, green: 0.55, blue: 0.79, alpha: 1.0)
])
backgroundGradient?.draw(in: outerPath, angle: -35)

let highlight = NSBezierPath(ovalIn: NSRect(x: 160, y: 640, width: 420, height: 200))
NSColor.white.withAlphaComponent(0.08).setFill()
highlight.fill()

let coverRect = NSRect(x: 262, y: 156, width: 500, height: 712)
let coverPath = NSBezierPath(roundedRect: coverRect, xRadius: 96, yRadius: 96)
NSColor.white.withAlphaComponent(0.97).setFill()
coverPath.fill()

let coverStroke = NSBezierPath(roundedRect: coverRect, xRadius: 96, yRadius: 96)
coverStroke.lineWidth = 2
NSColor(calibratedRed: 0.10, green: 0.21, blue: 0.42, alpha: 0.12).setStroke()
coverStroke.stroke()

let spineRect = NSRect(x: 262, y: 156, width: 112, height: 712)
let spinePath = NSBezierPath(roundedRect: spineRect, xRadius: 96, yRadius: 96)
let spineGradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.12, green: 0.31, blue: 0.61, alpha: 1.0),
    NSColor(calibratedRed: 0.18, green: 0.48, blue: 0.80, alpha: 1.0)
])
spineGradient?.draw(in: spinePath, angle: 90)

let spineAccent = NSBezierPath()
spineAccent.move(to: NSPoint(x: 376, y: 244))
spineAccent.line(to: NSPoint(x: 376, y: 780))
spineAccent.lineWidth = 4
spineAccent.lineCapStyle = .round
NSColor.white.withAlphaComponent(0.24).setStroke()
spineAccent.stroke()

let contentLineColor = NSColor(calibratedRed: 0.77, green: 0.84, blue: 0.93, alpha: 1.0)
for (offset, width) in [(CGFloat(0), CGFloat(220)), (CGFloat(64), CGFloat(188)), (CGFloat(128), CGFloat(228))] {
    let line = NSBezierPath()
    line.move(to: NSPoint(x: 430, y: 686 - offset))
    line.line(to: NSPoint(x: 430 + width, y: 686 - offset))
    line.lineWidth = 12
    line.lineCapStyle = .round
    contentLineColor.setStroke()
    line.stroke()
}

let foldPath = NSBezierPath()
foldPath.move(to: NSPoint(x: 620, y: 868))
foldPath.line(to: NSPoint(x: 762, y: 868))
foldPath.line(to: NSPoint(x: 762, y: 730))
foldPath.close()
let foldGradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.97, green: 0.34, blue: 0.24, alpha: 1.0),
    NSColor(calibratedRed: 0.84, green: 0.16, blue: 0.12, alpha: 1.0)
])
foldGradient?.draw(in: foldPath, angle: -45)

let foldInner = NSBezierPath()
foldInner.move(to: NSPoint(x: 652, y: 868))
foldInner.line(to: NSPoint(x: 762, y: 758))
foldInner.lineWidth = 5
foldInner.lineCapStyle = .round
NSColor.white.withAlphaComponent(0.35).setStroke()
foldInner.stroke()

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0]) else {
    fputs("Failed to encode PNG data.\n", stderr)
    exit(1)
}

do {
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try pngData.write(to: outputURL, options: .atomic)
    print("Generated icon base: \(outputURL.path)")
} catch {
    fputs("Failed to write PNG: \(error.localizedDescription)\n", stderr)
    exit(1)
}
