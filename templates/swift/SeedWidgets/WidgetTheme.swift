// SOURCE: proven in a shipped production app.
//
// Widget-surface palette. Deliberately SEPARATE from Seed/Theme/AppTheme.swift:
// a widget extension is its own process and cannot reliably read the host
// app's theme environment. Mirror the AppTheme hex values here so the
// widget looks like the app — but never `import` the app's theme.
//
// Per docs/WIDGETS.md rule 6: ≤2 font weights, ≤1 accent per widget.

import SwiftUI
import UIKit

/// The widget extension's standalone palette. Wizard substitutes these
/// hex values from `DECISIONS/002-palette.md` alongside AppTheme at
/// `/new-app --commit` time — keep them in sync with `Seed/Theme/AppTheme.swift`.
///
/// Each token resolves a **light/dark hex pair** against the rendering
/// environment's `userInterfaceStyle`, mirroring `AppTheme.dynamic`. This is
/// not optional polish: widgets and especially **Live Activities render on the
/// Lock Screen**, which is frequently a dark surface. A fixed light-only widget
/// palette paints dark text + dark-on-dark art against the system's dark Live
/// Activity background and reads as black/blank when the user leaves the app
/// (a real bug we shipped in production). Keep the dark column in sync with
/// `AppTheme`'s dark hexes.
enum WidgetTheme {
    static let surface          = dynamic(light: 0xF7F2EA, dark: 0x1B1712)
    static let surfaceSecondary = dynamic(light: 0xEFE7D8, dark: 0x272019)
    static let onSurface          = dynamic(light: 0x2A2520, dark: 0xF0E9DC)
    static let onSurfaceSecondary = dynamic(light: 0x5A4F45, dark: 0xA89C88)
    static let accent     = dynamic(light: 0x9E5A35, dark: 0xCE8C5A)
    static let accentDeep = dynamic(light: 0x744228, dark: 0xE3AE82)

    /// Resolves a light/dark hex pair against the active appearance, so one
    /// token works in both modes with no call-site change.
    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            uiColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    private static func uiColor(hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
