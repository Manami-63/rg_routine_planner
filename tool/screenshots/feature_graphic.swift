// Google Play feature graphic (1024 x 500): icon, app name and tagline.
//
//   swift tool/screenshots/feature_graphic.swift <icon.png> <out.png> "<tagline>"
import AppKit

let a = CommandLine.arguments
let iconImage = NSImage(contentsOfFile: a[1])!
var r = CGRect(origin: .zero, size: iconImage.size)
let icon = iconImage.cgImage(forProposedRect: &r, context: nil, hints: nil)!
let W: CGFloat = 1024, H: CGFloat = 500
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8,
  bytesPerRow: 0, space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.interpolationQuality = .high
let top = CGColor(srgbRed: 0x6B/255, green: 0x1F/255, blue: 0x73/255, alpha: 1)
let bottom = CGColor(srgbRed: 0x4E/255, green: 0x04/255, blue: 0x53/255, alpha: 1)
let gradient = CGGradient(colorsSpace: space, colors: [top, bottom] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: H), end: CGPoint(x: W, y: 0), options: [])

let side: CGFloat = 260
let iconRect = CGRect(x: 90, y: (H - side) / 2, width: side, height: side)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 24, color: CGColor(gray: 0, alpha: 0.4))
let path = CGPath(roundedRect: iconRect, cornerWidth: side * 0.22, cornerHeight: side * 0.22, transform: nil)
ctx.addPath(path); ctx.setFillColor(bottom); ctx.fillPath()
ctx.restoreGState()
ctx.saveGState(); ctx.addPath(path); ctx.clip(); ctx.draw(icon, in: iconRect); ctx.restoreGState()

func draw(_ text: String, size: CGFloat, weight: NSFont.Weight, alpha: CGFloat, y: CGFloat) {
  let s = NSAttributedString(string: text, attributes: [
    .font: NSFont.systemFont(ofSize: size, weight: weight),
    .foregroundColor: NSColor(white: 1, alpha: alpha),
  ])
  let line = CTLineCreateWithAttributedString(s)
  ctx.textPosition = CGPoint(x: 400, y: y)
  CTLineDraw(line, ctx)
}
draw("RG Routine Lab", size: 64, weight: .bold, alpha: 1, y: 262)
draw(a[3], size: 30, weight: .medium, alpha: 0.85, y: 205)

let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
CGImageDestinationFinalize(dest)
