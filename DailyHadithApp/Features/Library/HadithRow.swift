import SwiftUI

struct HadithRow: View {
    let hadith: AudioHadith
    let totalCount: Int
    let isCurrent: Bool
    let isPlaying: Bool
    let isListened: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(hadith.title)
                    .font(.callout.weight(isCurrent ? .semibold : .regular))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 5) {
                    Text(hadith.displaySequence)
                    Text("·")
                    Text(hadith.durationText)
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            .layoutPriority(1)

            HadithRowStatus(isPlaying: isPlaying, isCurrent: isCurrent, isListened: isListened)
        }
        .padding(.vertical, 12)
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
