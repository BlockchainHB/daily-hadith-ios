import SwiftUI

struct SettingsView: View {
    let loadState: LibraryLoadState
    let playbackStore: PlaybackStore
    @ObservedObject var progressStore: ListeningProgressStore

    @State private var resetConfirmation: ResetProgressConfirmation?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SettingsHero()

                settingsContent
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, -98)
                    .padding(.bottom, 104)
            }
        }
        .background(AppTheme.warmBackground)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.container, edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            "Reset listening progress?",
            isPresented: Binding(
                get: { resetConfirmation != nil },
                set: { isPresented in
                    if !isPresented {
                        resetConfirmation = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                resetProgress()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears listened items and saved playback positions.")
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 16) {
                sectionStack
            }
        } else {
            sectionStack
        }
    }

    private var sectionStack: some View {
        VStack(spacing: 16) {
            SettingsGlassSection(title: "Support") {
                Link(destination: AppLinks.charity) {
                    SettingsActionRow(
                        icon: "heart",
                        iconColor: AppTheme.primaryGreen,
                        title: "Donate to Islamic Relief",
                        detail: "Support those in need.",
                        accessory: .externalLink
                    )
                }
                .buttonStyle(.plain)
            }

            SettingsGlassSection(title: "Manage") {
                Button(role: .destructive) {
                    resetConfirmation = .allProgress
                } label: {
                    SettingsActionRow(
                        icon: "arrow.counterclockwise",
                        iconColor: .red,
                        title: "Reset Progress",
                        detail: "Clear listened history and saved positions.",
                        accessory: nil
                    )
                }
                .buttonStyle(.plain)
            }

            SettingsGlassSection(title: "About") {
                VStack(spacing: 0) {
                    SettingsInfoRow(
                        icon: "book.closed",
                        iconColor: AppTheme.primaryGreen,
                        title: "Library",
                        detail: "\(libraryCount) audio hadiths"
                    )

                    SettingsDivider()

                    SettingsTranslationRow(
                        acknowledged: progressStore.translationNoticeAcknowledged,
                        acknowledge: progressStore.acknowledgeTranslationNotice
                    )

                    SettingsDivider()

                    Link(destination: AppLinks.privacyPolicy) {
                        SettingsActionRow(
                            icon: "hand.raised",
                            iconColor: AppTheme.primaryGreen,
                            title: "Privacy Policy",
                            detail: "How Daily Hadith handles data.",
                            accessory: .externalLink
                        )
                    }
                    .buttonStyle(.plain)

                    SettingsDivider()

                    Link(destination: AppLinks.support) {
                        SettingsActionRow(
                            icon: "questionmark.circle",
                            iconColor: AppTheme.mutedGold,
                            title: "Support",
                            detail: "Contact us for help or corrections.",
                            accessory: .externalLink
                        )
                    }
                    .buttonStyle(.plain)

                    SettingsDivider()

                    SettingsInfoRow(
                        icon: "info",
                        iconColor: .secondary,
                        title: "Version",
                        detail: Bundle.main.appVersion
                    )
                }
            }

            DedicationCard()
        }
    }

    private var snapshot: LibrarySnapshot? {
        if case .loaded(let snapshot) = loadState {
            return snapshot
        }
        return nil
    }

    private var libraryCount: Int {
        snapshot?.count ?? 0
    }

    private func resetProgress() {
        progressStore.resetAllProgress(snapshot: snapshot)
        playbackStore.stop()
        if let first = snapshot?.first {
            playbackStore.load(hadith: first)
        }
    }
}

private enum AppLinks {
    static let charity = URL(string: "https://www.islamic-relief.org/")!
    static let privacyPolicy = URL(string: "https://blockchainhb.github.io/daily-hadith-ios/privacy.html")!
    static let support = URL(string: "https://blockchainhb.github.io/daily-hadith-ios/support.html")!
}

private struct SettingsHero: View {
    private let heroHeight: CGFloat = 362

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                Image("DailyHeader")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: heroHeight)
                    .clipped()
                    .saturation(1.04)
                    .contrast(1.02)
            }

            heroReadabilityWash
            heroBottomFade

            VStack(alignment: .leading, spacing: 8) {
                Text("ترتیبات")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(AppTheme.ink.opacity(0.66))
                    .environment(\.layoutDirection, .rightToLeft)

                Text("Settings")
                    .font(.system(size: 44, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.ink)

                Text("Customize your experience.")
                    .font(.body)
                    .foregroundStyle(AppTheme.ink.opacity(0.62))
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 116)
        }
        .frame(height: heroHeight)
    }

    private var heroReadabilityWash: some View {
        LinearGradient(
            stops: [
                .init(color: AppTheme.heroWash.opacity(0.82), location: 0),
                .init(color: AppTheme.heroWash.opacity(0.66), location: 0.34),
                .init(color: AppTheme.heroWash.opacity(0.20), location: 0.62),
                .init(color: AppTheme.heroWash.opacity(0.02), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var heroBottomFade: some View {
        LinearGradient(
            stops: [
                .init(color: Color.clear, location: 0),
                .init(color: Color.clear, location: 0.56),
                .init(color: AppTheme.warmBackground.opacity(0.30), location: 0.78),
                .init(color: AppTheme.warmBackground.opacity(0.96), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct SettingsGlassSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(AppTheme.mutedGold)

            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .glassSurface(cornerRadius: AppTheme.cardCornerRadius)
    }
}

private struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let detail: String
    let accessory: SettingsRowAccessory?

    var body: some View {
        HStack(spacing: 12) {
            SettingsGlyph(systemName: icon, color: iconColor)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                Text(detail)
                    .font(.subheadline)
                    .lineSpacing(2)
                    .foregroundStyle(AppTheme.ink.opacity(0.62))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let accessory {
                SettingsAccessoryIcon(accessory: accessory)
            }
        }
        .contentShape(Rectangle())
    }
}

private struct SettingsInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            SettingsGlyph(systemName: icon, color: iconColor)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.ink.opacity(0.62))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}

private struct SettingsTranslationRow: View {
    let acknowledged: Bool
    let acknowledge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                SettingsGlyph(systemName: "text.bubble", color: AppTheme.mutedGold)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Translation")
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                    Text("English text is generated from reviewed Urdu audio to preserve meaning. The Urdu audio remains the source of truth.")
                        .font(.subheadline)
                        .lineSpacing(2)
                        .foregroundStyle(AppTheme.ink.opacity(0.62))
                }
            }

            if !acknowledged {
                Button("Got It", action: acknowledge)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassSurface(cornerRadius: 16, interactive: true)
                    .padding(.leading, 60)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct DedicationCard: View {
    var body: some View {
        VStack(spacing: 14) {
            OrnamentalDivider()

            VStack(spacing: 8) {
                Text("For Kausar Bhatti")
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                Text("A daily hadith, shared with love and duas.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.ink.opacity(0.62))
                    .multilineTextAlignment(.center)
            }

            Image(systemName: "seal")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(AppTheme.mutedGold)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 26)
        .glassSurface(cornerRadius: AppTheme.cardCornerRadius)
    }
}

private struct SettingsGlyph: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .symbolVariant(.none)
            .font(.system(size: 23, weight: .regular))
            .foregroundStyle(color.opacity(0.94))
            .frame(width: 48, height: 48)
            .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .accessibilityHidden(true)
    }
}

private struct SettingsAccessoryIcon: View {
    let accessory: SettingsRowAccessory

    var body: some View {
        Image(systemName: accessory.systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppTheme.ink.opacity(0.66))
            .frame(width: 40, height: 40)
            .glassSurface(cornerRadius: 20)
            .accessibilityHidden(true)
    }
}

private enum SettingsRowAccessory {
    case externalLink

    var systemName: String {
        switch self {
        case .externalLink:
            "arrow.up.forward"
        }
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.hairline)
            .frame(height: 1)
            .padding(.leading, 60)
            .padding(.vertical, 13)
    }
}

private struct OrnamentalDivider: View {
    var body: some View {
        HStack(spacing: 11) {
            Rectangle()
                .frame(width: 58, height: 1)
            Image(systemName: "sparkle")
                .font(.system(size: 15, weight: .regular))
            Rectangle()
                .frame(width: 58, height: 1)
        }
        .foregroundStyle(AppTheme.mutedGold.opacity(0.72))
        .accessibilityHidden(true)
    }
}

enum ResetProgressConfirmation: Identifiable {
    case allProgress

    var id: String { "allProgress" }
}

private extension Bundle {
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview("Settings") {
    SettingsView(
        loadState: .loaded(PreviewFixtures.snapshot),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview)
    )
}
