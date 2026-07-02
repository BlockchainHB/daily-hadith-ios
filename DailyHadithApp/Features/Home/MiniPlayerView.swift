import SwiftUI

struct MiniPlayerView: View {
    let hadith: AudioHadith
    @ObservedObject var playbackStore: PlaybackStore

    var body: some View {
        HStack(spacing: 12) {
            titleStack
                .layoutPriority(1)

            Button(action: playbackStore.togglePlay) {
                Image(systemName: playbackStore.state.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 42, height: 42)
            }
            .foregroundStyle(AppTheme.primaryGreen)
            .accessibilityLabel(playbackStore.state.isPlaying ? "Pause" : "Play")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, minHeight: 62)
    }

    private var titleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(hadith.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Text("\(DurationFormatter.format(playbackStore.elapsed)) / \(hadith.durationText)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

extension UserDefaults {
    static var preview: UserDefaults {
        let defaults = UserDefaults(suiteName: "daily-hadith.preview")!
        defaults.removePersistentDomain(forName: "daily-hadith.preview")
        return defaults
    }
}
