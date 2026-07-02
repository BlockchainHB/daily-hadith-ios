import SwiftUI

struct LibraryView: View {
    let loadState: LibraryLoadState
    let playbackStore: PlaybackStore
    @ObservedObject var progressStore: ListeningProgressStore
    let onLibraryPlaybackStarted: () -> Void

    @State private var searchText = ""
    @State private var activeRoute: LibraryRoute?

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
        .background(AppTheme.warmBackground)
    }

    private func loadedContent(_ snapshot: LibrarySnapshot) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                LibraryHero(
                    searchText: $searchText,
                    onSearchSubmit: submitSearch
                )

                LibrarySectionHeader(title: "Browse by Theme")
                    .padding(.top, -38)
                    .padding(.bottom, 14)

                LibraryThemeGrid(
                    themeCounts: snapshot.themeCounts,
                    selectTheme: { theme in
                        activeRoute = .theme(theme)
                    }
                )

                LibrarySectionHeader(title: "All Hadiths")
                    .padding(.top, 28)
                    .padding(.bottom, 8)

                HadithList(
                    hadiths: snapshot.hadiths,
                    totalCount: snapshot.count,
                    isListened: progressStore.isListened,
                    select: { hadith in
                        playFromLibrary(hadith)
                    }
                )
                .padding(.bottom, 108)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppTheme.warmBackground)
        .ignoresSafeArea(.container, edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: isShowingRoute) {
            if let activeRoute {
                resultsView(for: activeRoute, in: snapshot)
            }
        }
    }

    private var isShowingRoute: Binding<Bool> {
        Binding(
            get: { activeRoute != nil },
            set: { isShowing in
                if !isShowing {
                    activeRoute = nil
                }
            }
        )
    }

    private func submitSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        activeRoute = .search(query)
        searchText = ""
    }

    private func resultsView(for route: LibraryRoute, in snapshot: LibrarySnapshot) -> some View {
        let hadiths: [AudioHadith]
        let title: String
        let subtitle: String
        let prompt: String
        let initialQuery: String

        switch route {
        case .theme(let theme):
            hadiths = snapshot.hadiths(forTheme: theme.id)
            title = theme.title
            subtitle = "Hadiths grouped by \(theme.title.lowercased())."
            prompt = "Search \(theme.title.lowercased())"
            initialQuery = ""
        case .search(let query):
            hadiths = snapshot.hadiths
            title = "Search Results"
            subtitle = "Search your collection of hadith."
            prompt = "Search hadith"
            initialQuery = query
        }

        return LibraryResultsView(
            eyebrow: route.eyebrow,
            title: title,
            subtitle: subtitle,
            searchPrompt: prompt,
            hadiths: hadiths,
            totalCount: snapshot.count,
            search: snapshot.search,
            initialSearchText: initialQuery,
            isListened: progressStore.isListened,
            select: playFromLibrary
        )
    }

    private func playFromLibrary(_ hadith: AudioHadith) {
        onLibraryPlaybackStarted()
        playbackStore.load(
            hadith: hadith,
            savedPosition: progressStore.playbackPosition(for: hadith.id),
            autoplay: true
        )
    }
}

private enum LibraryRoute {
    case theme(HadithTheme)
    case search(String)

    var eyebrow: String {
        switch self {
        case .theme(let theme):
            theme.urduTitle
        case .search:
            "تلاش"
        }
    }
}

#Preview("Library") {
    LibraryView(
        loadState: .loaded(PreviewFixtures.snapshot),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview),
        onLibraryPlaybackStarted: {}
    )
}
