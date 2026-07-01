import SwiftUI

struct RootAppView: View {
    @StateObject private var playbackStore = PlaybackStore()
    @StateObject private var progressStore = ListeningProgressStore()
    @State private var selectedTab: AppTab = .home
    @State private var libraryLoadState: LibraryLoadState = .loading

    private let repository = HadithRepository()

    var body: some View {
        rootTabs
            .task {
                await loadLibrary()
            }
            .onReceive(playbackStore.$completedHadithID.compactMap { $0 }) { completedID in
                handleCompletedHadith(completedID)
            }
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
                progressStore: progressStore
            )
        case .library:
            LibraryView(
                loadState: libraryLoadState,
                playbackStore: playbackStore,
                progressStore: progressStore,
                openHome: { selectedTab = .home }
            )
        case .settings:
            SettingsView(
                loadState: libraryLoadState,
                playbackStore: playbackStore,
                progressStore: progressStore
            )
        }
    }

    private var shouldShowMiniPlayer: Bool {
        selectedTab == .library &&
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
                playbackStore: playbackStore,
                openHome: { selectedTab = .home }
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
                playbackStore.load(hadith: current, savedPosition: progressStore.playbackPosition(for: current.id))
            }
        } catch {
            libraryLoadState = .failed(error.localizedDescription)
        }
    }

    private func handleCompletedHadith(_ completedID: AudioHadith.ID) {
        guard let snapshot = libraryLoadState.snapshot else { return }
        progressStore.markListened(completedID)
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
