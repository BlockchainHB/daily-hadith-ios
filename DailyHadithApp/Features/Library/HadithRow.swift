import SwiftUI

struct HadithRow: View {
    let hadith: AudioHadith
    let totalCount: Int
    let isListened: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.controlSurface)
                    .frame(width: 40, height: 40)
                    .shadow(color: AppTheme.raisedShadow, radius: 8, x: 0, y: 4)

                Image(systemName: "play.fill")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .offset(x: 1)
            }
            .frame(width: 44, height: 44)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(hadith.title)
                    .font(.system(size: 16.5, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .layoutPriority(1)

            Text(hadith.durationText)
                .font(.callout.monospacedDigit())
                .foregroundStyle(AppTheme.mutedGold.opacity(0.86))
                .frame(minWidth: 42, alignment: .trailing)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var pieces = ["Hadith \(hadith.sequence) of \(totalCount)", hadith.title, hadith.durationText]
        if isListened {
            pieces.append("listened")
        }
        return pieces.joined(separator: ", ")
    }
}
