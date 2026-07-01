import SwiftUI

struct HadithRow: View {
    let hadith: AudioHadith
    let totalCount: Int
    let isCurrent: Bool
    let isPlaying: Bool
    let isListened: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Text(hadith.displaySequence)
                .font(.callout.weight(.medium).monospacedDigit())
                .foregroundStyle(isCurrent ? AppTheme.primaryGreen : .secondary)
                .frame(width: 38, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(hadith.title)
                    .font(.body.weight(isCurrent ? .semibold : .regular))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(hadith.durationText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            .layoutPriority(1)

            HadithRowStatus(isPlaying: isPlaying, isCurrent: isCurrent, isListened: isListened)
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var pieces = ["Hadith \(hadith.sequence) of \(totalCount)", hadith.title, hadith.durationText]
        if isPlaying {
            pieces.append("playing")
        } else if isCurrent {
            pieces.append("current")
        }
        if isListened {
            pieces.append("listened")
        }
        return pieces.joined(separator: ", ")
    }
}
