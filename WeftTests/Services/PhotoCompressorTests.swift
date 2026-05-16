import Foundation
import Testing
import UIKit
@testable import Weft

@MainActor
struct PhotoCompressorTests {
    /// Builds a known-size solid-color JPEG in-memory so tests don't depend on
    /// any bundled asset. Returns roughly `size × size` pixels.
    /// Renders at scale=1 so the produced JPEG is exactly `width × height`
    /// pixels regardless of the simulator's screen scale. Without this, an
    /// iPhone 17 Pro simulator at @3x silently triples every test dimension.
    private func sampleJPEG(width: Int, height: Int, quality: CGFloat = 1.0) -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: width, height: height),
            format: format
        )
        let image = renderer.image { ctx in
            UIColor(red: 0.36, green: 0.48, blue: 0.4, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        return image.jpegData(compressionQuality: quality) ?? Data()
    }

    @Test
    func resizeDownscalesOversizedImage() throws {
        let raw = sampleJPEG(width: 4000, height: 3000)
        let image = try #require(UIImage(data: raw))
        let resized = PhotoCompressor.resize(image, maxDimension: 1600)

        #expect(resized.size.width <= 1600)
        #expect(resized.size.height <= 1600)
        // Aspect ratio preserved (3000/4000 = 0.75; 1200/1600 = 0.75)
        let ratio = resized.size.height / resized.size.width
        #expect(abs(ratio - 0.75) < 0.01, "aspect ratio drift: got \(ratio)")
    }

    @Test
    func resizeLeavesSmallImageUntouched() throws {
        let raw = sampleJPEG(width: 800, height: 600)
        let image = try #require(UIImage(data: raw))
        let resized = PhotoCompressor.resize(image, maxDimension: 1600)

        #expect(resized.size.width == 800)
        #expect(resized.size.height == 600)
    }

    @Test
    func compressReturnsJPEGData() throws {
        let raw = sampleJPEG(width: 4000, height: 3000)
        let compressed = try #require(PhotoCompressor.compress(raw))

        // JPEG magic header bytes.
        #expect(compressed[0] == 0xFF)
        #expect(compressed[1] == 0xD8)
    }

    @Test
    func compressShrinksDataSubstantially() throws {
        // A solid color compresses absurdly well, so to test that we're doing
        // resize + recompress (not just recompress), feed a noisy image.
        // Force scale=1 so dimensions match what the test asserts.
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: 4000, height: 3000),
            format: format
        )
        let image = renderer.image { _ in
            for x in stride(from: 0, to: 4000, by: 8) {
                for y in stride(from: 0, to: 3000, by: 8) {
                    let r = CGFloat(x % 256) / 256
                    let g = CGFloat(y % 256) / 256
                    let b = CGFloat((x + y) % 256) / 256
                    UIColor(red: r, green: g, blue: b, alpha: 1).setFill()
                    UIRectFill(CGRect(x: x, y: y, width: 8, height: 8))
                }
            }
        }
        let raw = image.jpegData(compressionQuality: 1.0) ?? Data()
        let compressed = try #require(PhotoCompressor.compress(raw))

        #expect(compressed.count < raw.count, "Expected compression: \(raw.count) → \(compressed.count)")
        // A 4000×3000 noisy JPEG at q=0.7 capped to 1600px should land well under 1MB.
        #expect(compressed.count < 1_000_000, "Compressed size too large: \(compressed.count) bytes")
    }

    @Test
    func compressReturnsNilForGarbageInput() {
        let garbage = Data([0x00, 0x01, 0x02, 0x03])
        #expect(PhotoCompressor.compress(garbage) == nil)
    }
}
