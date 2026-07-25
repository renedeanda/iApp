// SOURCE: new — Seed template; shared spacing scale.
// Sibling of Typography + AppTheme: the rhythm every surface shares.

import SwiftUI

/// The shared 4-based spacing scale. Views go through these tokens for
/// padding and stack spacing — exactly as they go through `Typography`
/// for type and `AppTheme` for color. One scale, repeated across every
/// surface, is what gives an app its vertical rhythm.
///
/// Intra-component micro-gaps (a 2pt name/detail pair, a thumbnail
/// inset) stay as literals — those aren't rhythm. These tokens are for
/// the spacing a user actually reads as structure.
enum Spacing {
    /// 4 pt — hairline gaps, tight button clusters.
    static let xs: CGFloat = 4
    /// 8 pt — a headline and its supporting line; tight pairs.
    static let sm: CGFloat = 8
    /// 12 pt — related elements within a card or row.
    static let md: CGFloat = 12
    /// 16 pt — the default surface padding and grid gutter.
    static let lg: CGFloat = 16
    /// 24 pt — section separation; empty / done-state rhythm.
    static let xl: CGFloat = 24
    /// 32 pt — hero breathing room (empty-state copy width).
    static let xxl: CGFloat = 32
}
