import SwiftUI

struct GlassSurface: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?
    let interactive: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                if let tint {
                    content
                        .glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
                } else {
                    content
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                }
            } else {
                if let tint {
                    content
                        .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
                } else {
                    content
                        .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                }
            }
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                }
        }
    }
}

extension View {
    func glassSurface(
        cornerRadius: CGFloat = AppTheme.cardCornerRadius,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        modifier(GlassSurface(cornerRadius: cornerRadius, tint: tint, interactive: interactive))
    }
}
