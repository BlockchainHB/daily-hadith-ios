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
        VStack(spacing: 12) {
            WaveformProgressView(progress: playbackProgress)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .layoutPriority(1)

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
            .tint(AppTheme.ink)
            .accessibilityLabel("Playback position")
            .accessibilityValue("\(DurationFormatter.format(playbackStore.elapsed)) of \(DurationFormatter.format(duration))")

            HStack {
                Text(DurationFormatter.format(playbackStore.elapsed))
                Spacer()
                Text("-\(DurationFormatter.format(max(duration - playbackStore.elapsed, 0)))")
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)

            PlaybackTransportControls(
                playbackStore: playbackStore,
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
        .padding(.horizontal, 18)
        .padding(.vertical, 2)
    }

    private var playbackProgress: Double {
        guard duration > 0 else { return 0 }
        return min(max(playbackStore.elapsed / duration, 0), 1)
    }
}

private struct PlaybackTransportControls: View {
    @ObservedObject var playbackStore: PlaybackStore
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            transportButton(
                systemName: "backward.end.fill",
                label: "Previous Hadith",
                prominence: .outer,
                action: previous
            )

            transportButton(
                systemName: "gobackward.15",
                label: "Rewind 15 seconds",
                prominence: .secondary
            ) {
                playbackStore.skip(by: -15)
            }

            transportButton(
                systemName: playbackStore.state.isPlaying ? "pause.fill" : "play.fill",
                label: playbackStore.state.isPlaying ? "Pause" : "Play",
                prominence: .primary,
                action: playbackStore.togglePlay
            )

            transportButton(
                systemName: "goforward.15",
                label: "Forward 15 seconds",
                prominence: .secondary
            ) {
                playbackStore.skip(by: 15)
            }

            transportButton(
                systemName: "forward.end.fill",
                label: "Next Hadith",
                prominence: .outer,
                action: next
            )
        }
        .frame(maxWidth: 300)
        .frame(maxWidth: .infinity)
    }

    private func transportButton(
        systemName: String,
        label: String,
        prominence: TransportProminence,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .symbolVariant(.fill)
                .font(.system(size: prominence.iconSize, weight: .semibold))
                .foregroundStyle(prominence.foreground)
                .frame(width: prominence.visualSize, height: prominence.visualSize)
                .background(prominence.background, in: Circle())
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private enum TransportProminence {
    case primary
    case secondary
    case outer

    var visualSize: CGFloat {
        switch self {
        case .primary: 42
        case .secondary: 38
        case .outer: 36
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .primary: 16
        case .secondary: 18
        case .outer: 15
        }
    }

    var foreground: Color {
        switch self {
        case .primary: .white
        case .secondary: AppTheme.ink.opacity(0.62)
        case .outer: AppTheme.ink.opacity(0.48)
        }
    }

    var background: Color {
        switch self {
        case .primary: AppTheme.primaryGreen
        case .secondary: AppTheme.ink.opacity(0.045)
        case .outer: Color.clear
        }
    }
}
