import SwiftUI

struct AboutSection: View {
    let libraryCount: Int
    let translationNoticeAcknowledged: Bool
    let acknowledgeTranslationNotice: () -> Void

    var body: some View {
        Section("About") {
            LabeledContent {
                Text("\(libraryCount) audio hadiths")
                    .foregroundStyle(.secondary)
            } label: {
                HStack(spacing: 11) {
                    SettingsRowIcon(systemName: "music.note.list", color: AppTheme.primaryGreen)
                    Text("Library")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 11) {
                    SettingsRowIcon(systemName: "text.bubble.fill", color: AppTheme.mutedGold)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Translation")
                            .font(.body)
                        Text("English text is generated from reviewed Urdu audio to preserve meaning. The Urdu audio remains the source of truth.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if !translationNoticeAcknowledged {
                    Button("Got It", action: acknowledgeTranslationNotice)
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(.bordered)
                        .tint(AppTheme.primaryGreen)
                }
            }
            .padding(.vertical, 4)

            LabeledContent {
                Text(Bundle.main.appVersion)
                    .foregroundStyle(.secondary)
            } label: {
                HStack(spacing: 11) {
                    SettingsRowIcon(systemName: "info", color: .secondary)
                    Text("Version")
                }
            }
        }
    }
}

private extension Bundle {
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
