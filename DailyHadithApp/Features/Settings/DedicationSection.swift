import SwiftUI

struct DedicationSection: View {
    var body: some View {
        Section {
            VStack(spacing: 6) {
                Text("Made for Kausar Bhatti")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("With love, duas, and a hadith for each day.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}
