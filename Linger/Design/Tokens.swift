import SwiftUI

extension Color {
    static let bg = Color("bg", bundle: .main, fallback: Color(red: 0.973, green: 0.961, blue: 0.937))
    static let bgDeep = Color("bgDeep", bundle: .main, fallback: Color(red: 0.937, green: 0.918, blue: 0.878))
    static let surface = Color("surface", bundle: .main, fallback: .white)
    static let surface2 = Color(
        "surface2",
        bundle: .main,
        fallback: Color(red: 0.980, green: 0.969, blue: 0.941)
    )
    static let ink = Color("ink", bundle: .main, fallback: Color(red: 0.106, green: 0.102, blue: 0.090))
    static let muted = Color("muted", bundle: .main, fallback: Color(red: 0.420, green: 0.408, blue: 0.384))
    static let whisper = Color(
        "whisper",
        bundle: .main,
        fallback: Color(red: 0.612, green: 0.596, blue: 0.557)
    )

    static let sage = Color("sage", bundle: .main, fallback: Color(red: 0.361, green: 0.478, blue: 0.400))
    static let sageSoft = Color(
        "sageSoft",
        bundle: .main,
        fallback: Color(red: 0.725, green: 0.796, blue: 0.745)
    )
    static let sageWash = Color(
        "sageWash",
        bundle: .main,
        fallback: Color(red: 0.894, green: 0.922, blue: 0.890)
    )
    static let sageInk = Color(
        "sageInk",
        bundle: .main,
        fallback: Color(red: 0.184, green: 0.290, blue: 0.220)
    )

    static let warm = Color("warm", bundle: .main, fallback: Color(red: 0.776, green: 0.541, blue: 0.227))
    static let warmSoft = Color(
        "warmSoft",
        bundle: .main,
        fallback: Color(red: 0.894, green: 0.773, blue: 0.541)
    )
    static let warmWash = Color(
        "warmWash",
        bundle: .main,
        fallback: Color(red: 0.961, green: 0.902, blue: 0.784)
    )
}

private extension Color {
    /// Pulls a named color from the asset catalog when present, falling back to a literal Color.
    /// SwiftUI returns a placeholder if the named color is missing, so we wrap the lookup.
    init(_ name: String, bundle: Bundle, fallback: Color) {
        if UIColor(named: name, in: bundle, compatibleWith: nil) != nil {
            self = Color(name, bundle: bundle)
        } else {
            self = fallback
        }
    }
}

enum LingerFont {
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
