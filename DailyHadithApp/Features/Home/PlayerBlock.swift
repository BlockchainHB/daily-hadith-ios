import SwiftUI

struct PlayerBlock: View {
    let hadith: AudioHadith
    @ObservedObject var playbackStore: PlaybackStore
    let previous: () -> Void
    let next: () -> Void

    @State private var isEditingScrubber = false
    @State private var scrubberValue: TimeInterval = 0

    private var duration: TimeInterval {
        playbackStore.duration > 0 ? playbackStore.duration : hadith.durationSeconds
    }

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 6) {
                Slider(
                    value: Binding(
                        get: { isEditingScrubber ? scrubberValue : min(playbackStore.elapsed, duration) },
                        set: { newValue in
                            scrubberValue = newValue
                            isEditingScrubber = true
                        }
                    ),
                    in: 0...max(duration, 1),
                    onEditingChanged: { editing in
                        isEditingScrubber = editing
                        if !editing {
                            playbackStore.seek(to: scrubberValue)
                        }
                    }
                )
                .tint(AppTheme.primaryGreen)
                .accessibilityLabel("Playback position")
                .accessibilityValue("\(DurationFormatter.format(playbackStore.elapsed)) of \(DurationFormatter.format(duration))")

                HStack {
                    Text(DurationFormatter.format(playbackStore.elapsed))
                    Spacer()
                    Text("-\(DurationFormatter.format(max(duration - playbackStore.elapsed, 0)))")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }

            TransportControls(
                isPlaying: playbackStore.state.isPlaying,
                playPause: playbackStore.togglePlay,
                rewind: { playbackStore.skip(by: -15) },
                forward: { playbackStore.skip(by: 15) },
                previous: previous,
                next: next
            )

            if case .failed(let message) = playbackStore.state {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .playerSurface()
    }
}
