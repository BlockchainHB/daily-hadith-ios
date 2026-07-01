import SwiftUI

struct TranslationExcerpt: View {
    let hadith: AudioHadith
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("English Translation")
                .font(.headline.weight(.semibold))

            Text(hadith.translation)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.primary)
                .lineLimit(isExpanded ? nil : 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)

            if shouldShowExpansionControl {
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Show Less" : "Read More")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.primaryGreen)
            }

            if hadith.hasManualReviewNote {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Review note")
                        .font(.subheadline.weight(.semibold))
                    Text(noteText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }

    private var noteText: String {
        let issues = hadith.reviewIssues.joined(separator: " ")
        return [issues, hadith.uncertaintyNote]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private var shouldShowExpansionControl: Bool {
        hadith.translation.count > 720
    }
}
