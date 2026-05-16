import Foundation
import UIKit

/// Resizes a raw image (from PhotosPicker / camera) and re-encodes it as JPEG.
/// Goal: keep the typical photo under ~400KB so iCloud sync stays cheap and
/// device storage stays sustainable across years of notes. The downscale is
/// deliberately aggressive — Weft displays photos at iPhone widths, never
/// poster size, so storing originals would be wasteful.
enum PhotoCompressor {
    /// Maximum size in points on the longest edge after resize.
    static let maxDimension: CGFloat = 1600
    /// JPEG compression quality. 0.7 strikes the usual visual / size balance
    /// for photographs; goes much higher → diminishing returns, much lower →
    /// visible artifacting on faces.
    static let jpegQuality: CGFloat = 0.7

    /// Returns compressed JPEG bytes, or `nil` if the input isn't decodable.
    /// Pure function — safe to call off the main thread.
    static func compress(_ rawData: Data) -> Data? {
        guard let image = UIImage(data: rawData) else { return nil }
        let resized = resize(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: jpegQuality)
    }

    /// Aspect-preserving resize. Returns the original if it's already smaller
    /// than the cap on both edges (no point burning a re-encode on a small
    /// image that's already in shape).
    static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longestEdge = max(size.width, size.height)
        guard longestEdge > maxDimension else { return image }

        let scale = maxDimension / longestEdge
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        // Force scale=1 so output pixel dimensions match the target. Without
        // this, the renderer uses the device's screen scale (3× on most
        // iPhones), tripling the pixel count and undoing the compression.
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
