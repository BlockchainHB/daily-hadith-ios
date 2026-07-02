import SwiftUI

struct LibraryResultsView: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let searchPrompt: String
    let hadiths: [AudioHadith]
    let totalCount: Int
    let search: ([AudioHadith], String) -> [AudioHadith]
    let isListened: (AudioHadith.ID) -> Bool
    let select: (AudioHadith) -> Void

    @State private var searchText: String
    @State private var visibleHadiths: [AudioHadith]
    @State private var resolvedQuery: String

    init(
        eyebrow: String,
        title: String,
        subtitle: String,
        searchPrompt: String = "Search hadith",
        hadiths: [AudioHadith],
        totalCount: Int,
        search: @escaping ([AudioHadith], String) -> [AudioHadith] = LibraryResultsView.defaultSearch,
        initialSearchText: String = "",
        isListened: @escaping (AudioHadith.ID) -> Bool,
        select: @escaping (AudioHadith) -> Void
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.searchPrompt = searchPrompt
        self.hadiths = hadiths
        self.totalCount = totalCount
        self.search = search
        self.isListened = isListened
        self.select = select
        self._searchText = State(initialValue: initialSearchText)
        self._visibleHadiths = State(initialValue: search(hadiths, initialSearchText))
        self._resolvedQuery = State(initialValue: initialSearchText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LibraryHero(
                    eyebrow: eyebrow,
                    title: title,
                    subtitle: resolvedSubtitle,
                    searchPrompt: searchPrompt,
                    searchText: $searchText
                )

                HadithList(
                    hadiths: visibleHadiths,
                    totalCount: totalCount,
                    isListened: isListened,
                    select: select
                )
                .padding(.top, -38)
                .padding(.bottom, 108)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppTheme.warmBackground)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.container, edges: .top)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: searchText) { _ in
            updateSearchResults()
        }
    }

    private var resolvedSubtitle: String {
        let query = resolvedQuery
        guard !query.isEmpty else { return subtitle }
        let resultWord = visibleHadiths.count == 1 ? "result" : "results"
        return "\(visibleHadiths.count) \(resultWord) for \"\(query)\"."
    }

    private func updateSearchResults() {
        resolvedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        visibleHadiths = search(hadiths, searchText)
    }

    private static func defaultSearch(hadiths: [AudioHadith], query: String) -> [AudioHadith] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return hadiths }
        return hadiths.filter { hadith in
            hadith.title.localizedCaseInsensitiveContains(normalizedQuery) ||
                (hadith.titleUrdu?.localizedCaseInsensitiveContains(normalizedQuery) ?? false) ||
                hadith.summary.localizedCaseInsensitiveContains(normalizedQuery) ||
                hadith.translation.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }
}

#Preview("Theme Results") {
    LibraryResultsView(
        eyebrow: "ایمان",
        title: "Faith",
        subtitle: "Hadiths grouped by faith.",
        hadiths: PreviewFixtures.snapshot.hadiths,
        totalCount: PreviewFixtures.snapshot.count,
        isListened: { _ in false },
        select: { _ in }
    )
}
