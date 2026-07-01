import SwiftUI

struct CurrentHadithHeader: View {
    let hadith: AudioHadith
    let currentIndex: Int
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hadith \(currentIndex) of \(totalCount)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.primaryGreen)

            Text(hadith.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
