// SOURCE: proven in a shipped production app.
// Palette tokens + surface system; wizard overrides hex per /pick-palette.

import SwiftUI
import UIKit

/// The Sprout template's palette tokens.
///
/// Warm-minimal default per CLAUDE.md taste rule 5 — never use #FFF or
/// #000 directly anywhere; palette is the source of truth.
///
/// Each token resolves a **light/dark hex pair** against the active
/// `userInterfaceStyle`, so a generated app has a working dark
/// appearance from the first build — never light surfaces leaking
/// under dark system chrome. `/pick-palette` designs both appearances
/// (taste rule 5) and writes a light *and* a dark token table into
/// `DECISIONS/002-palette.md`; the wizard substitutes both sets of hex
/// here at `/new-app --commit` time. `ThemeContrastTests` checks AAA
/// contrast in both appearances.
///
/// Source pattern: proven in a shipped production app.
enum AppTheme {
    // Surfaces — three levels of foreground/background depth.
    static let surface          = dynamic(light: 0xE8EBE3, dark: 0x181B14)
    static let surfaceSecondary = dynamic(light: 0xDADFD2, dark: 0x242821)
    static let surfaceTertiary  = dynamic(light: 0xC8CFC0, dark: 0x30352C)

    // Text — primary + secondary on the surface.
    static let onSurface          = dynamic(light: 0x21261E, dark: 0xE4E8DF)
    static let onSurfaceSecondary = dynamic(light: 0x5A6051, dark: 0xA8B0A0)

    // Accent — departed Sage moss. The accent brightens in dark so it carries
    // on the near-black surface; `accentDeep` is the higher-emphasis
    // accent (chips, links) — darker than `accent` on light, lighter
    // on dark. ΔE2000 ≥ 15 vs every claimed accent in PORTFOLIO.md.
    static let accent     = dynamic(light: 0x5F7A55, dark: 0x93AC89)
    static let accentDeep = dynamic(light: 0x46603F, dark: 0xB2C7A9)
    static let onAccent   = surface

    // Launch background. Referenced from project.yml's UILaunchScreen
    // UIColorName so the first frame matches the app — the Assets
    // `LaunchBackground` colorset carries its own light/dark pair.
    static let launchBackground = surface

    /// Resolves a light/dark hex pair against the active appearance,
    /// so one token works in both modes with no call-site change.
    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            uiColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    /// Builds a fully-opaque sRGB `UIColor` from a `0xRRGGBB` literal.
    private static func uiColor(hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
