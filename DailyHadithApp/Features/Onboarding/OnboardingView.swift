import SwiftUI

struct OnboardingView: View {
    let finish: (_ remindersEnabled: Bool, _ reminderTime: DailyReminderTime) async -> Bool

    @Environment(\.colorScheme) private var colorScheme
    @State private var page = 0
    @State private var remindersEnabled = true
    @State private var reminderDate = DailyReminderTime.morning.asDate()
    @State private var isFinishing = false
    @State private var notificationDenied = false

    private let pageCount = 5

    var body: some View {
        ZStack {
            AppTheme.warmBackground.ignoresSafeArea()
            backgroundImage
            backgroundFade

            VStack(spacing: 0) {
                topBar

                TabView(selection: $page) {
                    WelcomeOnboardingPage()
                        .tag(0)
                    RitualOnboardingPage()
                        .tag(1)
                    ListenOnboardingPage()
                        .tag(2)
                    UnderstandOnboardingPage()
                        .tag(3)
                    ReminderOnboardingPage(
                        remindersEnabled: $remindersEnabled,
                        reminderDate: $reminderDate,
                        notificationDenied: notificationDenied
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.snappy(duration: 0.34), value: page)

                footer
            }
        }
        .tint(AppTheme.primaryGreen)
        .interactiveDismissDisabled()
    }

    private var topBar: some View {
        HStack {
            if page > 0 {
                Button {
                    withAnimation(.snappy(duration: 0.28)) {
                        page -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                        .frame(width: 46, height: 46)
                        .glassSurface(cornerRadius: 23, interactive: true)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            } else {
                Color.clear
                    .frame(width: 46, height: 46)
            }

            Spacer()

            if page > 0 && page < pageCount - 1 {
                Button("Skip") {
                    withAnimation(.snappy(duration: 0.28)) {
                        page = pageCount - 1
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.mutedGold)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, AppTheme.screenPadding)
        .padding(.top, 18)
        .frame(height: 72)
    }

    private var footer: some View {
        VStack(spacing: 18) {
            PageDots(page: page, pageCount: pageCount)

            if page == pageCount - 1 {
                Text("May Allah bless your day")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.mutedGold.opacity(0.84))
            }

            Button {
                advance()
            } label: {
                HStack(spacing: 8) {
                    if isFinishing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(page == pageCount - 1 ? "Start listening" : page == 0 ? "Get started" : "Continue")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.primaryGreen, in: Capsule())
                .shadow(color: AppTheme.primaryGreen.opacity(colorScheme == .dark ? 0.18 : 0.28), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(isFinishing)
        }
        .padding(.horizontal, AppTheme.screenPadding + 12)
        .padding(.bottom, 28)
    }

    private var backgroundImage: some View {
        GeometryReader { proxy in
            let heroHeight = proxy.size.height * (page == 0 ? 0.57 : 0.48)

            Image("DailyHeader")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: heroHeight, alignment: .topTrailing)
                .clipped()
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black.opacity(0.96), location: 0.42),
                            .init(color: .black.opacity(0.52), location: 0.72),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: AppTheme.heroWash.opacity(colorScheme == .dark ? 0.72 : 0.82), location: 0),
                            .init(color: AppTheme.heroWash.opacity(colorScheme == .dark ? 0.45 : 0.56), location: 0.36),
                            .init(color: Color.clear, location: 0.72)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask {
                        LinearGradient(
                            colors: [.black, .black.opacity(0.56), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .opacity(page == 0 ? 0.52 : 0.36)
                .saturation(colorScheme == .dark ? 0.86 : 1.03)
                .contrast(colorScheme == .dark ? 0.94 : 1.03)
                .blur(radius: page == 0 ? 0 : 0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea()
    }

    private var backgroundFade: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: AppTheme.heroWash.opacity(colorScheme == .dark ? 0.46 : 0.22), location: 0),
                    .init(color: AppTheme.warmBackground.opacity(0.08), location: 0.34),
                    .init(color: AppTheme.warmBackground.opacity(0.84), location: 0.66),
                    .init(color: AppTheme.warmBackground, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    AppTheme.mutedGold.opacity(colorScheme == .dark ? 0.12 : 0.22),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }

    private func advance() {
        if page < pageCount - 1 {
            withAnimation(.snappy(duration: 0.28)) {
                page += 1
            }
            return
        }

        isFinishing = true
        Task {
            let didSchedule = await finish(
                remindersEnabled,
                DailyReminderTime.from(reminderDate)
            )
            await MainActor.run {
                notificationDenied = remindersEnabled && !didSchedule
                isFinishing = false
            }
        }
    }
}

private struct WelcomeOnboardingPage: View {
    var body: some View {
        OnboardingPageShell(bottomAnchored: true, bottomPadding: 34) {
            VStack(alignment: .leading, spacing: 14) {
                Text("السلام عليكم")
                    .font(.system(size: 29, weight: .regular, design: .default))
                    .foregroundStyle(AppTheme.ink.opacity(0.64))
                    .environment(\.layoutDirection, .rightToLeft)

                Text("Daily\nHadith")
                    .font(.system(size: 50, weight: .semibold, design: .default))
                    .lineSpacing(-1)
                    .foregroundStyle(AppTheme.ink)

                Text("A hadith a day, recited in Urdu and understood in English.")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .lineSpacing(3)
                    .foregroundStyle(AppTheme.ink.opacity(0.68))
                    .frame(maxWidth: 310, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct RitualOnboardingPage: View {
    var body: some View {
        OnboardingPageShell {
            OnboardingTextBlock(
                eyebrow: "THE DAILY RITUAL",
                title: "One hadith,\nevery morning.",
                message: "Open the app to continue through the collection in order, one peaceful listen at a time."
            )

            PreviewHadithCard()
        }
    }
}

private struct ListenOnboardingPage: View {
    var body: some View {
        OnboardingPageShell {
            OnboardingTextBlock(
                eyebrow: "LISTEN",
                title: "In clear Urdu,\nread aloud.",
                message: "The audio is ready offline, with familiar controls for listening, pausing, and returning later."
            )

            OnboardingGlassCard {
                VStack(spacing: 18) {
                    Text("قرآنی واقعات سے نبی کی سچائی")
                        .font(.title3.weight(.regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.ink.opacity(0.82))
                        .environment(\.layoutDirection, .rightToLeft)

                    WaveformProgressView(progress: 0.28)
                        .frame(height: 58)

                    Slider(value: .constant(70), in: 0...305)
                        .tint(AppTheme.ink)
                        .disabled(true)

                    HStack {
                        Text("1:10")
                        Spacer()
                        Text("-3:55")
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(AppTheme.ink.opacity(0.58))

                    HStack(spacing: 18) {
                        OnboardingTransportIcon("backward.end.fill", opacity: 0.48)
                        OnboardingTransportIcon("gobackward.15", opacity: 0.62)
                        Image(systemName: "play.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(AppTheme.primaryGreen, in: Circle())
                        OnboardingTransportIcon("goforward.15", opacity: 0.62)
                        OnboardingTransportIcon("forward.end.fill", opacity: 0.48)
                    }
                }
            }
        }
    }
}

private struct UnderstandOnboardingPage: View {
    var body: some View {
        OnboardingPageShell {
            OnboardingTextBlock(
                eyebrow: "UNDERSTAND",
                title: "Every word,\nin English.",
                message: "A reviewed English rendering helps preserve the meaning while the Urdu audio remains the source."
            )

            OnboardingGlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("TRANSLATION")
                        .font(.caption.weight(.semibold))
                        .tracking(1.6)
                        .foregroundStyle(AppTheme.mutedGold)

                    Text("Reflecting on the hadith becomes easier when the meaning is close at hand. Read a clear English version, then return to the audio whenever you need.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .lineSpacing(5)
                        .foregroundStyle(AppTheme.ink.opacity(0.76))
                }
            }
        }
    }
}

private struct ReminderOnboardingPage: View {
    @Binding var remindersEnabled: Bool
    @Binding var reminderDate: Date
    let notificationDenied: Bool

    var body: some View {
        OnboardingPageShell {
            OnboardingTextBlock(
                eyebrow: "STAY CLOSE",
                title: "A gentle\ndaily reminder.",
                message: "Choose the time that fits your routine. You can change it later in Settings."
            )

            OnboardingGlassCard {
                VStack(spacing: 18) {
                    HStack(spacing: 13) {
                        Image(systemName: "bell")
                            .font(.system(size: 21, weight: .regular))
                            .foregroundStyle(AppTheme.primaryGreen)
                            .frame(width: 46, height: 46)
                            .background(AppTheme.primaryGreen.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily reminder")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppTheme.ink)
                            Text("One notification each day")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.ink.opacity(0.58))
                        }

                        Spacer()

                        Toggle("Daily reminder", isOn: $remindersEnabled)
                            .labelsHidden()
                    }

                    Divider()
                        .overlay(AppTheme.hairline)

                    DatePicker(
                        "Reminder time",
                        selection: $reminderDate,
                        displayedComponents: .hourAndMinute
                    )
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppTheme.ink)
                    .disabled(!remindersEnabled)
                    .opacity(remindersEnabled ? 1 : 0.42)

                    if notificationDenied {
                        Text("Notifications were not enabled. You can allow them later in iPhone Settings.")
                            .font(.footnote)
                            .lineSpacing(2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

private struct OnboardingPageShell<Content: View>: View {
    var bottomAnchored = false
    var bottomPadding: CGFloat = 18
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            if bottomAnchored {
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 26) {
                content
            }

            if !bottomAnchored {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, AppTheme.screenPadding + 12)
        .padding(.top, 8)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OnboardingTextBlock: View {
    let eyebrow: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(eyebrow)
                .font(.caption.weight(.bold))
                .tracking(1.8)
                .foregroundStyle(AppTheme.mutedGold)

            Text(title)
                .font(.system(size: 42, weight: .semibold, design: .default))
                .lineSpacing(-2)
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(message)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .lineSpacing(4)
                .foregroundStyle(AppTheme.ink.opacity(0.66))
                .frame(maxWidth: 340, alignment: .leading)
        }
    }
}

private struct PreviewHadithCard: View {
    var body: some View {
        OnboardingGlassCard {
            VStack(spacing: 17) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("TODAY'S HADITH")
                        .font(.caption.weight(.semibold))
                        .tracking(1.6)
                        .foregroundStyle(AppTheme.mutedGold)
                    Text("July 2, 2026 · Hadith 004")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.ink.opacity(0.52))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                OrnamentalOnboardingDivider()

                Text("Patience and Calmness\nLoved by Allah")
                    .font(.system(size: 27, weight: .regular, design: .serif))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.ink)

                WaveformProgressView(progress: 0.18)
                    .frame(height: 40)

                HStack {
                    Text("0:00")
                    Spacer()
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(AppTheme.primaryGreen, in: Circle())
                    Spacer()
                    Text("-6:50")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(AppTheme.ink.opacity(0.58))
            }
        }
    }
}

private struct OnboardingGlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .glassSurface(cornerRadius: 30)
    }
}

private struct OnboardingTransportIcon: View {
    let systemName: String
    let opacity: Double

    init(_ systemName: String, opacity: Double) {
        self.systemName = systemName
        self.opacity = opacity
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(AppTheme.ink.opacity(opacity))
            .frame(width: 44, height: 44)
    }
}

private struct OrnamentalOnboardingDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, AppTheme.mutedGold.opacity(0.55)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 64, height: 1)
            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppTheme.mutedGold)
            Rectangle()
                .fill(LinearGradient(colors: [AppTheme.mutedGold.opacity(0.55), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(width: 64, height: 1)
        }
        .accessibilityHidden(true)
    }
}

private struct PageDots: View {
    let page: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AppTheme.primaryGreen : AppTheme.ink.opacity(0.16))
                    .frame(width: index == page ? 22 : 6, height: 6)
            }
        }
        .animation(.snappy(duration: 0.24), value: page)
        .accessibilityLabel("Page \(page + 1) of \(pageCount)")
    }
}

#Preview("Onboarding") {
    OnboardingView { _, _ in true }
}
