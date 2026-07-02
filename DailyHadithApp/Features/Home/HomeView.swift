import SwiftUI

struct HomeView: View {
    let loadState: LibraryLoadState
    let playbackStore: PlaybackStore
    @ObservedObject var progressStore: ListeningProgressStore
    let onDailyPlaybackActivated: () -> Void

    @State private var lastSavedPosition: TimeInterval = 0

    var body: some View {
        Group {
            switch loadState {
            case .loading:
                LoadingStateView(title: "Loading library")
            case .failed(let message):
                ErrorStateView(message: message)
            case .loaded(let snapshot):
                loadedContent(snapshot)
            }
        }
    }

    private func loadedContent(_ snapshot: LibrarySnapshot) -> some View {
        let hadith = snapshot.hadith(id: progressStore.currentHadithID) ?? snapshot.first

        return ScrollView {
            VStack(spacing: 0) {
                HomeHero()

                if let hadith {
                    VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                        VStack(alignment: .leading, spacing: 18) {
                            CurrentHadithHeader(
                                hadith: hadith
                            )

                            PlayerBlock(
                                hadith: hadith,
                                playbackStore: playbackStore,
                                previous: {
                                    move(to: snapshot.hadith(before: hadith.id), preservingPlayback: playbackStore.state.isPlaying)
                                },
                                next: {
                                    move(to: snapshot.hadith(after: hadith.id), preservingPlayback: playbackStore.state.isPlaying)
                                }
                            )
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 20)
                        .padding(.bottom, 18)
                        .glassSurface(cornerRadius: AppTheme.cardCornerRadius)

                        TranslationExcerpt(hadith: hadith)
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, -98)
                    .padding(.bottom, 104)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onAppear {
                        onDailyPlaybackActivated()
                        ensureLoaded(hadith)
                    }
                    .onChange(of: progressStore.currentHadithID) { _ in
                        if let current = snapshot.hadith(id: progressStore.currentHadithID) {
                            ensureLoaded(current)
                        }
                    }
                    .onReceive(playbackStore.$elapsed) { elapsed in
                        savePositionIfNeeded(elapsed)
                    }
                }
            }
        }
        .background(AppTheme.warmBackground)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.container, edges: .top)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func ensureLoaded(_ hadith: AudioHadith) {
        guard playbackStore.currentHadithID != hadith.id else { return }
        onDailyPlaybackActivated()
        playbackStore.load(hadith: hadith, savedPosition: progressStore.playbackPosition(for: hadith.id))
    }

    private func move(to hadith: AudioHadith?, preservingPlayback shouldAutoplay: Bool) {
        guard let hadith else { return }
        onDailyPlaybackActivated()
        progressStore.setCurrentHadith(hadith.id)
        playbackStore.load(
            hadith: hadith,
            savedPosition: progressStore.playbackPosition(for: hadith.id),
            autoplay: shouldAutoplay
        )
    }

    private func savePositionIfNeeded(_ elapsed: TimeInterval) {
        guard let id = playbackStore.currentHadithID, elapsed > 0 else { return }
        guard abs(elapsed - lastSavedPosition) >= 5 else { return }
        lastSavedPosition = elapsed
        progressStore.savePlaybackPosition(elapsed, for: id)
    }
}

#Preview("Loaded") {
    HomeView(
        loadState: .loaded(PreviewFixtures.snapshot),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview),
        onDailyPlaybackActivated: {}
    )
}

#Preview("Error") {
    HomeView(
        loadState: .failed("Preview missing resource."),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview),
        onDailyPlaybackActivated: {}
    )
}
