// Puts a caption above a screenshot on a plum background, for the stores.
//
//   swift tool/screenshots/frame.swift <in.png> <out.png> <width> <height> "<caption>"
import AppKit
import CoreText

let a = CommandLine.arguments
let shot = NSImage(contentsOfFile: a[1])!
var r = CGRect(origin: .zero, size: shot.size)
let image = shot.cgImage(forProposedRect: &r, context: nil, hints: nil)!
let W = CGFloat(Int(a[3])!), H = CGFloat(Int(a[4])!)
let caption = a[5]

let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8,
  bytesPerRow: 0, space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.interpolationQuality = .high

// Background: the icon's plum, a little lighter at the top.
let top = CGColor(srgbRed: 0x6B/255, green: 0x1F/255, blue: 0x73/255, alpha: 1)
let bottom = CGColor(srgbRed: 0x4E/255, green: 0x04/255, blue: 0x53/255, alpha: 1)
let gradient = CGGradient(colorsSpace: space, colors: [top, bottom] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])

// Caption, centred in the top area (CG origin is bottom-left).
let captionArea = H * 0.17
let font = NSFont.systemFont(ofSize: W * 0.072, weight: .bold)
let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
paragraph.lineHeightMultiple = 0.95
let text = NSAttributedString(string: caption, attributes: [
  .font: font, .foregroundColor: NSColor.white, .paragraphStyle: paragraph,
])
let framesetter = CTFramesetterCreateWithAttributedString(text)
let textWidth = W * 0.86
let fit = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil,
  CGSize(width: textWidth, height: captionArea), nil)
let textRect = CGRect(x: (W - textWidth) / 2, y: H - captionArea / 2 - fit.height / 2 - H * 0.01,
  width: textWidth, height: fit.height + 2)
CTFrameDraw(CTFramesetterCreateFrame(framesetter, CFRange(), CGPath(rect: textRect, transform: nil), nil), ctx)

// Screenshot below, scaled to fit, with rounded corners and a soft shadow.
let maxW = W * 0.84, maxH = H - captionArea - H * 0.03
let scale = min(maxW / CGFloat(image.width), maxH / CGFloat(image.height))
let sw = CGFloat(image.width) * scale, sh = CGFloat(image.height) * scale
let shotRect = CGRect(x: (W - sw) / 2, y: H - captionArea - sh, width: sw, height: sh)
let radius = sw * 0.075
let path = CGPath(roundedRect: shotRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -W * 0.01), blur: W * 0.04,
  color: CGColor(gray: 0, alpha: 0.45))
ctx.addPath(path); ctx.setFillColor(bottom); ctx.fillPath()
ctx.restoreGState()
ctx.saveGState()
ctx.addPath(path); ctx.clip()
ctx.draw(image, in: shotRect)
ctx.restoreGState()

let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
CGImageDestinationFinalize(dest)
