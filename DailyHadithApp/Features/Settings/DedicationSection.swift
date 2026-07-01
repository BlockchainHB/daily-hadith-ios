import SwiftUI

struct DedicationSection: View {
    var body: some View {
        Section {
            VStack(spacing: 8) {
                Text("Made for Kausar Bhatti")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text("With love, duas, and a hadith for each day.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
        .listRowBackground(Color.clear)
    }
}
