import SwiftUI

struct HadithRowStatus: View {
    let isPlaying: Bool
    let isCurrent: Bool
    let isListened: Bool

    var body: some View {
        Group {
            if let symbolName {
                Image(systemName: symbolName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 30, height: 30)
                    .background(backgroundColor, in: Circle())
            }
        }
        .frame(width: 30, height: 30)
        .accessibilityHidden(true)
    }

    private var symbolName: String? {
        if isPlaying { return "speaker.wave.2.fill" }
        if isListened { return "checkmark.circle.fill" }
        return nil
    }

    private var color: Color {
        if isPlaying { return .white }
        if isListened { return AppTheme.primaryGreen }
        return Color(.tertiaryLabel)
    }

    private var backgroundColor: Color {
        if isPlaying { return AppTheme.primaryGreen }
        if isListened { return AppTheme.softGreen }
        return .clear
    }
}
