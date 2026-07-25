import SwiftUI
import Testing
import UIKit
@testable import Seed

/// Verifies the active palette tokens meet WCAG AAA contrast on
/// primary text/background pairs — in **both** light and dark
/// appearances.
///
/// AAA thresholds (per WCAG 2.2):
/// - 7.0:1 for body text (< 18pt)
/// - 4.5:1 for large text (≥ 18pt, or ≥ 14pt bold)
///
/// The test resolves `AppTheme` tokens against an explicit
/// `UITraitCollection` via `UIColor.resolvedColor(with:)`, so a
/// palette change in AppTheme.swift propagates here automatically and
/// a regression in *either* appearance fails the suite. This is the
/// value gate for dark mode: a generated app cannot ship a dark
/// palette that fails contrast.
@Suite("Theme contrast")
struct ThemeContrastTests {
    @Test func bodyTextOnSurfacePassesAAA_light() throws {
        let ratio = contrastRatio(
            of: rgb(of: AppTheme.onSurface, in: .light),
            on: rgb(of: AppTheme.surface, in: .light)
        )
        #expect(ratio >= 7.0, "Light body text contrast \(ratio) fails AAA (≥ 7:1 required)")
    }

    @Test func bodyTextOnSurfacePassesAAA_dark() throws {
        let ratio = contrastRatio(
            of: rgb(of: AppTheme.onSurface, in: .dark),
            on: rgb(of: AppTheme.surface, in: .dark)
        )
        #expect(ratio >= 7.0, "Dark body text contrast \(ratio) fails AAA (≥ 7:1 required)")
    }

    @Test func secondaryTextOnSurfacePassesLargeText_light() throws {
        let ratio = contrastRatio(
            of: rgb(of: AppTheme.onSurfaceSecondary, in: .light),
            on: rgb(of: AppTheme.surface, in: .light)
        )
        // Secondary text is captions / metadata — AA Large (≥ 4.5:1) acceptable.
        #expect(ratio >= 4.5, "Light secondary text contrast \(ratio) fails AA Large (≥ 4.5:1)")
    }

    @Test func secondaryTextOnSurfacePassesLargeText_dark() throws {
        let ratio = contrastRatio(
            of: rgb(of: AppTheme.onSurfaceSecondary, in: .dark),
            on: rgb(of: AppTheme.surface, in: .dark)
        )
        #expect(ratio >= 4.5, "Dark secondary text contrast \(ratio) fails AA Large (≥ 4.5:1)")
    }

    @Test func accentOnSurfacePassesLargeText_light() throws {
        let ratio = contrastRatio(
            of: rgb(of: AppTheme.accent, in: .light),
            on: rgb(of: AppTheme.surface, in: .light)
        )
        #expect(ratio >= 4.5, "Light accent contrast \(ratio) fails AA Large (≥ 4.5:1)")
    }

    @Test func accentOnSurfacePassesLargeText_dark() throws {
        let ratio = contrastRatio(
            of: rgb(of: AppTheme.accent, in: .dark),
            on: rgb(of: AppTheme.surface, in: .dark)
        )
        #expect(ratio >= 4.5, "Dark accent contrast \(ratio) fails AA Large (≥ 4.5:1)")
    }

    @Test func darkPaletteResolvesDistinctFromLight() throws {
        // Guards the dynamic-color bridge: if `UIColor(Color)` ever
        // flattened the dynamic provider, every `_dark` test above
        // would silently re-test the light value and still pass. This
        // turns that into a loud failure.
        let lightSurface = rgb(of: AppTheme.surface, in: .light)
        let darkSurface = rgb(of: AppTheme.surface, in: .dark)
        #expect(lightSurface != darkSurface, "Surface token did not resolve a distinct dark value — dark mode is not wired")
    }

    // MARK: - Color extraction + WCAG relative luminance

    private func rgb(
        of color: Color,
        in style: UIUserInterfaceStyle
    ) -> (r: Double, g: Double, b: Double) {
        let trait = UITraitCollection(userInterfaceStyle: style)
        let ui = UIColor(color).resolvedColor(with: trait)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    private func luminance(_ rgb: (r: Double, g: Double, b: Double)) -> Double {
        func channel(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(rgb.r) + 0.7152 * channel(rgb.g) + 0.0722 * channel(rgb.b)
    }

    private func contrastRatio(
        of foreground: (r: Double, g: Double, b: Double),
        on background: (r: Double, g: Double, b: Double)
    ) -> Double {
        let l1 = luminance(foreground)
        let l2 = luminance(background)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
}
