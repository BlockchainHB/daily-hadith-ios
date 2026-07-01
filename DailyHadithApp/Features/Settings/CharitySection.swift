import SwiftUI

struct CharitySection: View {
    var body: some View {
        Section("Charity") {
            Link(destination: URL(string: "https://www.islamic-relief.org/")!) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "heart.fill", color: AppTheme.primaryGreen)
                    Text("Donate to Islamic Relief")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}
