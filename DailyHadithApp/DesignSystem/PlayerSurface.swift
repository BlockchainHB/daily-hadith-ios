import SwiftUI

struct PlayerSurface: ViewModifier {
    let cornerRadius: CGFloat
    let interactive: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                content
                    .glassEffect(.regular.tint(AppTheme.softGreen.opacity(0.24)).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                content
                    .glassEffect(.regular.tint(AppTheme.softGreen.opacity(0.18)), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            content
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                }
        }
    }
}

extension View {
    func playerSurface(cornerRadius: CGFloat = AppTheme.playerCornerRadius, interactive: Bool = false) -> some View {
        modifier(PlayerSurface(cornerRadius: cornerRadius, interactive: interactive))
    }
}
