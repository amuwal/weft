import SwiftUI
import UIKit

extension Color {
    static let bg = dynamic(light: 0xF8F5EF, dark: 0x161410)
    static let bgDeep = dynamic(light: 0xEFEAE0, dark: 0x100E0B)
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x22201C)
    static let surface2 = dynamic(light: 0xFAF7F0, dark: 0x1B1916)

    static let ink = dynamic(light: 0x1B1A17, dark: 0xEDE8DC)
    static let muted = dynamic(light: 0x6B6862, dark: 0x8E8A82)
    static let whisper = dynamic(light: 0x9C988E, dark: 0x65615B)

    static let sage = dynamic(light: 0x5C7A66, dark: 0x7FA48A)
    static let sageSoft = dynamic(light: 0xB9CBBE, dark: 0x4A6B54)
    static let sageWash = dynamic(light: 0xE4EBE3, dark: 0x2A3A2E)
    static let sageInk = dynamic(light: 0x2F4A38, dark: 0xC5D6CB)

    static let warm = dynamic(light: 0xC68A3A, dark: 0xD5A767)
    static let warmSoft = dynamic(light: 0xE4C58A, dark: 0x8B6A3E)
    static let warmWash = dynamic(light: 0xF5E6C8, dark: 0x4A3B23)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

enum WeftFont {
    static let display: Font = .system(.largeTitle, design: .serif).weight(.medium)
    static let title: Font = .system(.title2, design: .default).weight(.semibold)
    static let serifBody: Font = .system(.body, design: .serif)
    static let body: Font = .system(.body)
    static let caption: Font = .system(.footnote, design: .rounded)
    static let mini: Font = .system(.caption2, design: .rounded).weight(.semibold)
}

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let ml: CGFloat = 16
    static let l: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let huge: CGFloat = 48
}

enum Radius {
    static let pill: CGFloat = 999
    static let card: CGFloat = 16
    static let cardLarge: CGFloat = 22
    static let sheet: CGFloat = 28
}
