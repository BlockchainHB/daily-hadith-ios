import SwiftUI

struct RootAppView: View {
    @StateObject private var playbackStore = PlaybackStore()
    @StateObject private var progressStore = ListeningProgressStore()
    @AppStorage("dailyHadith.onboardingCompleted.v1") private var hasCompletedOnboarding = false
    @AppStorage("dailyHadith.reminders.enabled.v1") private var remindersEnabled = false
    @AppStorage("dailyHadith.reminders.hour.v1") private var reminderHour = 8
    @AppStorage("dailyHadith.reminders.minute.v1") private var reminderMinute = 0
    @State private var selectedTab: AppTab = .home
    @State private var libraryLoadState: LibraryLoadState = .loading
    @State private var playbackOrigin: PlaybackOrigin = .daily

    private let repository = HadithRepository()

    var body: some View {
        rootTabs
            .task {
                await loadLibrary()
            }
            .fullScreenCover(isPresented: onboardingPresented) {
                OnboardingView(finish: finishOnboarding)
            }
            .onReceive(playbackStore.$completedHadithID.compactMap { $0 }) { completedID in
                handleCompletedHadith(completedID)
            }
    }

    private var onboardingPresented: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { isPresented in
                if !isPresented {
                    hasCompletedOnboarding = true
                }
            }
        )
    }

    @ViewBuilder
    private var rootTabs: some View {
        if #available(iOS 26.1, *) {
            tabView
                .tabViewBottomAccessory(isEnabled: shouldShowMiniPlayer) {
                    miniPlayerAccessory
                }
        } else {
            tabView
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if shouldShowMiniPlayer {
                        miniPlayerAccessory
                            .padding(.bottom, 10)
                    }
                }
        }
    }

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                NavigationStack {
                    content(for: tab)
                }
                .tabItem { tab.label }
                .tag(tab)
            }
        }
        .tint(AppTheme.primaryGreen)
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView(
                loadState: libraryLoadState,
                playbackStore: playbackStore,
                progressStore: progressStore,
                onDailyPlaybackActivated: {
                    playbackOrigin = .daily
                }
            )
        case .library:
            LibraryView(
                loadState: libraryLoadState,
                playbackStore: playbackStore,
                progressStore: progressStore,
                onLibraryPlaybackStarted: {
                    playbackOrigin = .library
                }
            )
        case .settings:
            SettingsView(
                loadState: libraryLoadState,
                playbackStore: playbackStore,
                progressStore: progressStore
            )
        }
    }

    @MainActor
    private func finishOnboarding(
        remindersEnabled shouldEnableReminders: Bool,
        reminderTime: DailyReminderTime
    ) async -> Bool {
        reminderHour = reminderTime.hour
        reminderMinute = reminderTime.minute
        remindersEnabled = shouldEnableReminders

        let didSchedule: Bool
        if shouldEnableReminders {
            didSchedule = await DailyReminderScheduler.scheduleDailyReminder(at: reminderTime)
            if !didSchedule {
                remindersEnabled = false
            }
        } else {
            DailyReminderScheduler.cancelDailyReminder()
            didSchedule = true
        }

        hasCompletedOnboarding = true
        return didSchedule
    }

    private var shouldShowMiniPlayer: Bool {
        selectedTab == .library &&
            playbackOrigin == .library &&
            libraryLoadState.snapshot != nil &&
            playbackStore.currentHadithID != nil &&
            playbackStore.shouldShowMiniPlayer
    }

    @ViewBuilder
    private var miniPlayerAccessory: some View {
        if let snapshot = libraryLoadState.snapshot,
           let hadith = playbackStore.currentHadith(in: snapshot) {
            MiniPlayerView(
                hadith: hadith,
                playbackStore: playbackStore
            )
        }
    }

    private func loadLibrary() async {
        do {
            let snapshot = try await repository.loadSnapshot()
            progressStore.prepareForLibrary(snapshot)
            libraryLoadState = .loaded(snapshot)
            if playbackStore.currentHadithID == nil,
               let current = snapshot.hadith(id: progressStore.currentHadithID) ?? snapshot.first {
                playbackOrigin = .daily
                playbackStore.load(hadith: current, savedPosition: progressStore.playbackPosition(for: current.id))
            }
        } catch {
            libraryLoadState = .failed(error.localizedDescription)
        }
    }

    private func handleCompletedHadith(_ completedID: AudioHadith.ID) {
        guard let snapshot = libraryLoadState.snapshot else { return }
        progressStore.markListened(completedID)
        guard completedID == progressStore.currentHadithID else { return }
        let next = snapshot.hadith(after: completedID) ?? snapshot.first
        guard let next else { return }
        progressStore.setCurrentHadith(next.id)
        playbackStore.load(hadith: next, savedPosition: progressStore.playbackPosition(for: next.id))
    }
}

private extension LibraryLoadState {
    var snapshot: LibrarySnapshot? {
        if case .loaded(let snapshot) = self {
            return snapshot
        }
        return nil
    }
}

private enum PlaybackOrigin {
    case daily
    case library
}
