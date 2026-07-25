// SOURCE: proven in a shipped production app.
//
// Alternate app icon options. The default (`seed`) is free; the rest are Pro.
// Two seasonal variants ship as a matched, portfolio-consistent INVERSE PAIR:
//
//   • Snow — near-black mark on a near-white field  (#0A0A0A on #F4F4F6)
//   • Noir — near-white mark on a near-black field  (#F4F4F6 on #0A0A0A)
//
// These exact hexes are the studio standard — Snow is the EXACT inverse of
// Noir (black-on-white like a printed page; Noir is white-on-black like a
// black-and-white film still). Do NOT tint them with the app's accent and do
// NOT use silver — that was tried and rejected. The mark is always THIS app's
// own silhouette, just rendered in those two neutral palettes.
//
// Naming: the dark B&W variant is "Noir" — never "Classic" (that conventionally
// means the *default* icon) and never "Black".
//
// SKIP these variants entirely if the app's PRIMARY icon is already
// black/white/monochrome (e.g. an ink-on-paper app, or a default that is
// already white-on-black) — a Snow/Noir there just duplicates what ships.
//
// Each case maps to an `AppIcon-<Name>.appiconset` in the asset catalog,
// produced by `bin/render-alt-icons.py`. Register every alternate in
// `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` (project.yml) or
// `CFBundleAlternateIcons` (Info.plist). See recipes/swift/add-alternate-icons.md.

import SwiftUI

enum AppIconOption: String, CaseIterable, Identifiable, Sendable {
    case seed   // default — free; resets to the primary AppIcon
    case snow   // seasonal — black-on-white (Pro)
    case noir   // black-and-white film — white-on-black (Pro)

    var id: String { rawValue }

    /// Default icon is free; alternates are Pro. Snow/Noir inherit this gate —
    /// they never change an app's monetization line for icons.
    var isPro: Bool { self != .seed }

    /// Asset-catalog name for `UIApplication.setAlternateIconName`. `nil` resets
    /// to the primary icon (the default case).
    var alternateIconName: String? {
        self == .seed ? nil : "AppIcon-\(rawValue.capitalized)"
    }

    /// Localized picker label. Keys live in `Localizable.xcstrings`
    /// (`appIcon.seed` / `appIcon.snow` / `appIcon.noir`). "Noir" stays the
    /// brand-style loanword in Latin scripts; transliterate for ja/ko/zh.
    var displayName: String {
        switch self {
        case .seed: String(localized: "appIcon.seed")
        case .snow: String(localized: "appIcon.snow")
        case .noir: String(localized: "appIcon.noir")
        }
    }

    /// Picker swatch — the field (background) color.
    var swatchField: Color {
        switch self {
        case .seed: AppTheme.surface          // app's own primary
        case .snow: Color(hex: 0xF4F4F6)       // near-white
        case .noir: Color(hex: 0x0A0A0A)       // near-black
        }
    }

    /// Picker swatch — the mark (foreground) color.
    var swatchMark: Color {
        switch self {
        case .seed: AppTheme.accent
        case .snow: Color(hex: 0x0A0A0A)       // near-black (inverse of Noir)
        case .noir: Color(hex: 0xF4F4F6)       // near-white
        }
    }
}

private extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
