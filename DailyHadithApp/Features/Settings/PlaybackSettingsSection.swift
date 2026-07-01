import SwiftUI

struct PlaybackSettingsSection: View {
    let resetProgress: () -> Void

    var body: some View {
        Section("Reset") {
            Button(role: .destructive, action: resetProgress) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "arrow.counterclockwise", color: .red)
                    Text("Reset Progress")
                }
            }
        }
    }
}
