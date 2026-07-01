import SwiftUI

struct HomeView: View {
    let loadState: LibraryLoadState
    @ObservedObject var playbackStore: PlaybackStore
    @ObservedObject var progressStore: ListeningProgressStore

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
        .navigationTitle("Daily Hadith")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadedContent(_ snapshot: LibrarySnapshot) -> some View {
        let hadith = snapshot.hadith(id: progressStore.currentHadithID) ?? snapshot.first

        return ScrollView {
            if let hadith {
                VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                    CurrentHadithHeader(
                        hadith: hadith,
                        currentIndex: (snapshot.index(of: hadith.id) ?? 0) + 1,
                        totalCount: snapshot.count
                    )

                    PlayerBlock(
                        hadith: hadith,
                        playbackStore: playbackStore,
                        previous: { playPrevious(from: hadith, in: snapshot) },
                        next: { playNext(from: hadith, in: snapshot) }
                    )

                    TranslationExcerpt(hadith: hadith)
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 104)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear {
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
        .background(AppTheme.warmBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ManualCompletionMenu(
                    isListened: hadith.map { progressStore.isListened($0.id) } ?? false,
                    markListened: {
                        if let hadith {
                            progressStore.markListened(hadith.id)
                        }
                    },
                    markUnlistened: {
                        if let hadith {
                            progressStore.markUnlistened(hadith.id)
                        }
                    }
                )
            }
        }
    }

    private func ensureLoaded(_ hadith: AudioHadith) {
        guard playbackStore.currentHadithID != hadith.id else { return }
        playbackStore.load(hadith: hadith, savedPosition: progressStore.playbackPosition(for: hadith.id))
    }

    private func playNext(from hadith: AudioHadith, in snapshot: LibrarySnapshot) {
        guard let next = snapshot.hadith(after: hadith.id) else { return }
        play(next)
    }

    private func playPrevious(from hadith: AudioHadith, in snapshot: LibrarySnapshot) {
        guard let previous = snapshot.hadith(before: hadith.id) else { return }
        play(previous)
    }

    private func play(_ hadith: AudioHadith) {
        progressStore.setCurrentHadith(hadith.id)
        playbackStore.load(hadith: hadith, savedPosition: progressStore.playbackPosition(for: hadith.id), autoplay: true)
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
        progressStore: ListeningProgressStore(defaults: .preview)
    )
}

#Preview("Error") {
    HomeView(
        loadState: .failed("Preview missing resource."),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview)
    )
}
