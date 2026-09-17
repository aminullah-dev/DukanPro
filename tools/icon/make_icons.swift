// DukanPro's app icon: a white «د» on the app's green, drawn at every size each
// platform asks for. It needs nothing but a Mac: CoreText shapes the letter with a
// system Arabic-script font, so anyone can redraw the icons.
//
//   swift tools/icon/make_icons.swift                  write every platform's icons
//   swift tools/icon/make_icons.swift --preview DIR    write 1024 px previews to DIR
//
// ICON_FONT=<PostScript name> tries another font (default GeezaPro-Bold).
import AppKit
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// #0F6B5C, the seed of the app's colour scheme (lib/main.dart).
let green = CGColor(srgbRed: 15 / 255, green: 107 / 255, blue: 92 / 255, alpha: 1)
let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
let letter = "د"
let fontName = ProcessInfo.processInfo.environment["ICON_FONT"] ?? "GeezaPro-Bold"

/// How the letter sits on its canvas.
enum Style {
    /// iOS: an opaque square; the system rounds the corners.
    case fullBleed
    /// Android before 8.0, and Windows: a rounded square on transparency.
    case rounded
    /// macOS: Apple's 824 px rounded square inside a 1024 px canvas.
    case macOS
    /// Android 8.0+ adaptive icon: the letter alone, well inside the 66 dp safe zone.
    case foreground
}

func font(_ size: CGFloat) -> CTFont { CTFontCreateWithName(fontName as CFString, size, nil) }

func line(_ size: CGFloat) -> CTLine {
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font(size),
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): white,
    ]
    return CTLineCreateWithAttributedString(NSAttributedString(string: letter, attributes: attributes))
}

func context(_ px: Int, opaque: Bool) -> CGContext {
    let alpha = opaque ? CGImageAlphaInfo.noneSkipLast : CGImageAlphaInfo.premultipliedLast
    let ctx = CGContext(
        data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: alpha.rawValue)!
    ctx.interpolationQuality = .high
    return ctx
}

func fillRounded(_ ctx: CGContext, _ rect: CGRect, radius: CGFloat) {
    ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    ctx.setFillColor(green)
    ctx.fillPath()
}

func render(_ px: Int, _ style: Style) -> CGImage {
    let s = CGFloat(px)
    let ctx = context(px, opaque: style == .fullBleed)

    // The share of the canvas the letter's ink may fill, along its longer side.
    let share: CGFloat
    switch style {
    case .fullBleed:
        ctx.setFillColor(green)
        ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))
        share = 0.50
    case .rounded:
        let rect = CGRect(x: 0, y: 0, width: s, height: s).insetBy(dx: s * 0.04, dy: s * 0.04)
        fillRounded(ctx, rect, radius: rect.width * 0.2)
        share = 0.46
    case .macOS:
        let side = s * 824 / 1024
        fillRounded(ctx, CGRect(x: (s - side) / 2, y: (s - side) / 2, width: side, height: side), radius: side * 0.225)
        share = 0.40
    case .foreground:
        share = 0.34
    }

    // Size the letter by its ink rather than its line box, then centre the ink.
    let probe = CTLineGetImageBounds(line(100), ctx)
    let sized = line(100 * (s * share) / max(probe.width, probe.height))
    let ink = CTLineGetImageBounds(sized, ctx)
    ctx.textPosition = CGPoint(x: (s - ink.width) / 2 - ink.minX, y: (s - ink.height) / 2 - ink.minY)
    CTLineDraw(sized, ctx)
    return ctx.makeImage()!
}

func png(_ image: CGImage) -> Data {
    let data = NSMutableData()
    let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("could not encode a PNG") }
    return data as Data
}

func write(_ data: Data, _ path: String) {
    let url = URL(fileURLWithPath: path)
    try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try! data.write(to: url)
    print("wrote", path)
}

/// A Windows .ico made of PNG images, which Windows has read since Vista.
func ico(_ sizes: [Int]) -> Data {
    let images = sizes.map { png(render($0, .rounded)) }
    var out = Data()
    func u16(_ value: Int) { withUnsafeBytes(of: UInt16(value).littleEndian) { out.append(contentsOf: $0) } }
    func u32(_ value: Int) { withUnsafeBytes(of: UInt32(value).littleEndian) { out.append(contentsOf: $0) } }
    u16(0); u16(1); u16(sizes.count)  // reserved, type 1 = icon, image count
    var offset = 6 + 16 * sizes.count
    for (px, image) in zip(sizes, images) {
        out.append(UInt8(px >= 256 ? 0 : px))  // width: 0 means 256
        out.append(UInt8(px >= 256 ? 0 : px))  // height
        out.append(0); out.append(0)           // palette size, reserved
        u16(1); u16(32)                        // colour planes, bits per pixel
        u32(image.count); u32(offset)
        offset += image.count
    }
    images.forEach { out.append($0) }
    return out
}

let arguments = CommandLine.arguments
if let flag = arguments.firstIndex(of: "--preview"), flag + 1 < arguments.count {
    let dir = arguments[flag + 1]
    print("font:", CTFontCopyPostScriptName(font(10)))
    write(png(render(1024, .fullBleed)), "\(dir)/ios-1024.png")
    write(png(render(1024, .macOS)), "\(dir)/macos-1024.png")
    // The adaptive icon as a round-masked launcher shows it: the visible 72 dp of 108 dp.
    let ctx = context(432, opaque: false)
    ctx.addEllipse(in: CGRect(x: 72, y: 72, width: 288, height: 288))
    ctx.setFillColor(green)
    ctx.fillPath()
    ctx.draw(render(432, .foreground), in: CGRect(x: 0, y: 0, width: 432, height: 432))
    write(png(ctx.makeImage()!), "\(dir)/android-adaptive-432.png")
    write(png(render(192, .rounded)), "\(dir)/android-legacy-192.png")
    exit(0)
}

guard FileManager.default.fileExists(atPath: "app/pubspec.yaml") else {
    fatalError("run this from the repository root")
}

let ios = "app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
for (name, px) in [
    ("20x20@1x", 20), ("20x20@2x", 40), ("20x20@3x", 60),
    ("29x29@1x", 29), ("29x29@2x", 58), ("29x29@3x", 87),
    ("40x40@1x", 40), ("40x40@2x", 80), ("40x40@3x", 120),
    ("60x60@2x", 120), ("60x60@3x", 180),
    ("76x76@1x", 76), ("76x76@2x", 152), ("83.5x83.5@2x", 167),
    ("1024x1024@1x", 1024),
] {
    write(png(render(px, .fullBleed)), "\(ios)/Icon-App-\(name).png")
}

let macOS = "app/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for px in [16, 32, 64, 128, 256, 512, 1024] {
    write(png(render(px, .macOS)), "\(macOS)/app_icon_\(px).png")
}

let res = "app/android/app/src/main/res"
for (density, legacy) in [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)] {
    write(png(render(legacy, .rounded)), "\(res)/mipmap-\(density)/ic_launcher.png")
    // Adaptive layers are 108 dp where a legacy icon is 48 dp.
    write(png(render(legacy * 108 / 48, .foreground)), "\(res)/mipmap-\(density)/ic_launcher_foreground.png")
}

write(ico([16, 24, 32, 48, 64, 256]), "app/windows/runner/resources/app_icon.ico")
