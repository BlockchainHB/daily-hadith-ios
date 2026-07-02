import SwiftUI
import UIKit

enum AppTheme {
    static let primaryGreen = adaptive(
        light: .init(0.04, 0.43, 0.29),
        dark: .init(0.14, 0.65, 0.44)
    )
    static let deepGreen = adaptive(
        light: .init(0.03, 0.24, 0.17),
        dark: .init(0.66, 0.92, 0.79)
    )
    static let softGreen = adaptive(
        light: .init(0.91, 0.96, 0.93),
        dark: .init(0.09, 0.15, 0.12)
    )
    static let warmBackground = adaptive(
        light: .init(0.97, 0.98, 0.97),
        dark: .init(0.035, 0.047, 0.045)
    )
    static let warmSurface = adaptive(
        light: .init(1.00, 1.00, 1.00),
        dark: .init(0.10, 0.12, 0.12)
    )
    static let mutedGold = adaptive(
        light: .init(0.70, 0.53, 0.22),
        dark: .init(0.80, 0.64, 0.34)
    )
    static let ink = adaptive(
        light: .init(0.08, 0.10, 0.14),
        dark: .init(0.91, 0.93, 0.90)
    )
    static let hairline = adaptive(
        light: .init(0.08, 0.10, 0.14, 0.08),
        dark: .init(1.00, 1.00, 1.00, 0.14)
    )
    static let heroWash = adaptive(
        light: .init(1.00, 1.00, 1.00),
        dark: .init(0.035, 0.047, 0.052)
    )
    static let controlSurface = adaptive(
        light: .init(1.00, 1.00, 1.00, 0.70),
        dark: .init(1.00, 1.00, 1.00, 0.12)
    )
    static let raisedShadow = adaptive(
        light: .init(0.00, 0.00, 0.00, 0.05),
        dark: .init(0.00, 0.00, 0.00, 0.35)
    )
    static let screenPadding: CGFloat = 18
    static let sectionSpacing: CGFloat = 16
    static let controlSize: CGFloat = 46
    static let playerCornerRadius: CGFloat = 28
    static let cardCornerRadius: CGFloat = 28

    private struct RGBA {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat

        init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }

    private static func adaptive(light: RGBA, dark: RGBA) -> Color {
        Color(UIColor { traits in
            let color = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        })
    }
}
