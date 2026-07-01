import SwiftUI

struct TranslationExcerpt: View {
    let hadith: AudioHadith
    @State private var isExpanded = false

    private var paragraphs: [String] {
        TranslationParagraphFormatter.paragraphs(from: hadith.translation)
    }

    private var displayedParagraphs: [String] {
        isExpanded ? paragraphs : Array(paragraphs.prefix(2))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Translation")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.mutedGold)
                .textCase(.uppercase)
                .tracking(1.1)

            VStack(alignment: .leading, spacing: 11) {
                ForEach(displayedParagraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.system(size: 15.5, weight: .regular, design: .default))
                        .lineSpacing(3)
                        .foregroundStyle(AppTheme.ink.opacity(0.90))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }

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
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .glassSurface(cornerRadius: AppTheme.cardCornerRadius)
    }

    private var noteText: String {
        let issues = hadith.reviewIssues.joined(separator: " ")
        return [issues, hadith.uncertaintyNote]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private var shouldShowExpansionControl: Bool {
        paragraphs.count > displayedParagraphs.count
    }
}

private enum TranslationParagraphFormatter {
    static func paragraphs(from text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let explicitParagraphs = trimmed
            .components(separatedBy: "\n\n")
            .map(clean)
            .filter { !$0.isEmpty }

        if explicitParagraphs.count > 1 {
            return explicitParagraphs
        }

        return sentenceGroups(from: trimmed)
    }

    private static func sentenceGroups(from text: String) -> [String] {
        let sentences = text
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: ". ")
            .map { sentence -> String in
                let cleaned = clean(sentence)
                guard !cleaned.isEmpty, !cleaned.hasSuffix(".") else { return cleaned }
                return "\(cleaned)."
            }
            .filter { !$0.isEmpty }

        guard sentences.count > 3 else {
            return [clean(text)]
        }

        return stride(from: 0, to: sentences.count, by: 3).map { start in
            let end = min(start + 3, sentences.count)
            return sentences[start..<end].joined(separator: " ")
        }
    }

    private static func clean(_ text: String) -> String {
        applyHonorifics(to: text)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func applyHonorifics(to text: String) -> String {
        var output = text
        let replacements = [
            "(peace and blessings be upon him)": "ﷺ",
            "(peace be upon him)": "ﷺ",
            "(Allah bless him and grant him peace)": "ﷺ",
            "peace and blessings be upon him": "ﷺ",
            "peace be upon him": "ﷺ",
            "Allah bless him and grant him peace": "ﷺ",
            "(may Allah be pleased with him)": "رضي الله عنه",
            "(may Allah be pleased with her)": "رضي الله عنها",
            "(may Allah be pleased with them)": "رضي الله عنهم",
            "may Allah be pleased with him": "رضي الله عنه",
            "may Allah be pleased with her": "رضي الله عنها",
            "may Allah be pleased with them": "رضي الله عنهم"
        ]

        for (phrase, replacement) in replacements {
            output = output.replacingOccurrences(of: phrase, with: replacement, options: [.caseInsensitive])
        }

        return output
    }
}
