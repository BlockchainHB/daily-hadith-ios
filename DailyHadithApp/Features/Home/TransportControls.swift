import SwiftUI

struct TransportControls: View {
    let isPlaying: Bool
    let playPause: () -> Void
    let rewind: () -> Void
    let forward: () -> Void
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            controlsRow(spacing: 18, sideSize: AppTheme.controlSize, playSize: 62, iconSize: 20)
            controlsRow(spacing: 10, sideSize: 38, playSize: 56, iconSize: 18)
        }
        .frame(maxWidth: .infinity)
    }

    private func controlsRow(spacing: CGFloat, sideSize: CGFloat, playSize: CGFloat, iconSize: CGFloat) -> some View {
        HStack(spacing: spacing) {
            playerButton("backward.end.fill", label: "Previous Hadith", size: sideSize, iconSize: iconSize, action: previous)
            playerButton("gobackward.15", label: "Rewind 15 seconds", size: sideSize, iconSize: iconSize, action: rewind)

            Button(action: playPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: playSize * 0.44, weight: .semibold))
                    .frame(width: playSize, height: playSize)
                    .background(AppTheme.primaryGreen, in: Circle())
                    .foregroundStyle(.white)
            }
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            playerButton("goforward.15", label: "Forward 15 seconds", size: sideSize, iconSize: iconSize, action: forward)
            playerButton("forward.end.fill", label: "Next Hadith", size: sideSize, iconSize: iconSize, action: next)
        }
    }

    private func playerButton(
        _ systemName: String,
        label: String,
        size: CGFloat,
        iconSize: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .frame(width: size, height: size)
                .background(AppTheme.softGreen.opacity(0.72), in: Circle())
        }
        .foregroundStyle(AppTheme.deepGreen)
        .accessibilityLabel(label)
    }
}
