import SwiftUI

struct CurrentHadithHeader: View {
    let hadith: AudioHadith

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 9) {
                Text("Today's Hadith")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedGold)
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text("\(Self.todayText) · Hadith \(hadith.displaySequence)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(AppTheme.ink.opacity(0.48))
            }

            VStack(spacing: 14) {
                if let titleUrdu = hadith.displayTitleUrdu {
                    Text(titleUrdu)
                        .font(.system(size: 21, weight: .regular, design: .default))
                        .foregroundStyle(AppTheme.ink.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .environment(\.layoutDirection, .rightToLeft)
                }

                OrnamentDivider()

                Text(hadith.title)
                    .font(.system(size: 21, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.ink.opacity(0.94))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static var todayText: String {
        Date.now.formatted(.dateTime.month(.wide).day().year())
    }
}

private struct OrnamentDivider: View {
    var body: some View {
        HStack(spacing: 10) {
            Capsule(style: .continuous)
                .fill(AppTheme.mutedGold.opacity(0.36))
                .frame(width: 72, height: 1)

            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppTheme.mutedGold)

            Capsule(style: .continuous)
                .fill(AppTheme.mutedGold.opacity(0.36))
                .frame(width: 72, height: 1)
        }
        .accessibilityHidden(true)
    }
}

private extension AudioHadith {
    var displayTitleUrdu: String? {
        guard let titleUrdu else { return nil }
        let trimmed = titleUrdu.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
