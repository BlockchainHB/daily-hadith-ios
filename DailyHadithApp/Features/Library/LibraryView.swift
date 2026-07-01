import SwiftUI

struct LibraryView: View {
    let loadState: LibraryLoadState
    @ObservedObject var playbackStore: PlaybackStore
    @ObservedObject var progressStore: ListeningProgressStore
    let openHome: () -> Void

    @State private var searchText = ""

    var body: some View {
        Group {
            switch loadState {
            case .loading:
                LoadingStateView(title: "Loading library")
            case .failed(let message):
                ErrorStateView(message: message)
            case .loaded(let snapshot):
                HadithList(
                    hadiths: filteredHadiths(from: snapshot),
                    totalCount: snapshot.count,
                    currentHadithID: progressStore.currentHadithID,
                    playingHadithID: playbackStore.state.isPlaying ? playbackStore.currentHadithID : nil,
                    isListened: progressStore.isListened,
                    select: { hadith in
                        progressStore.setCurrentHadith(hadith.id)
                        playbackStore.load(
                            hadith: hadith,
                            savedPosition: progressStore.playbackPosition(for: hadith.id),
                            autoplay: true
                        )
                        openHome()
                    }
                )
            }
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search titles")
        .background(AppTheme.warmBackground)
    }

    private func filteredHadiths(from snapshot: LibrarySnapshot) -> [AudioHadith] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return snapshot.hadiths }
        return snapshot.hadiths.filter { hadith in
            hadith.title.localizedCaseInsensitiveContains(query) ||
            hadith.summary.localizedCaseInsensitiveContains(query)
        }
    }
}

#Preview("Library") {
    LibraryView(
        loadState: .loaded(PreviewFixtures.snapshot),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview),
        openHome: {}
    )
}
