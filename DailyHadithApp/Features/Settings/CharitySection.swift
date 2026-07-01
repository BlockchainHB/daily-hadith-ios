import SwiftUI

struct CharitySection: View {
    var body: some View {
        Section("Charity") {
            Link(destination: URL(string: "https://www.islamic-relief.org/")!) {
                HStack(spacing: 11) {
                    SettingsRowIcon(systemName: "heart.fill", color: AppTheme.primaryGreen)
                    Text("Donate to Islamic Relief")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
