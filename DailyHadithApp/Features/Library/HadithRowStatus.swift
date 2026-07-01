import SwiftUI

struct HadithRowStatus: View {
    let isPlaying: Bool
    let isCurrent: Bool
    let isListened: Bool

    var body: some View {
        Group {
            if let symbolName {
                Image(systemName: symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }

    private var symbolName: String? {
        if isPlaying { return "speaker.wave.2.fill" }
        if isListened { return "checkmark.circle.fill" }
        return nil
    }

    private var color: Color {
        if isPlaying { return AppTheme.primaryGreen }
        if isListened { return .secondary }
        return Color(.tertiaryLabel)
    }
}
