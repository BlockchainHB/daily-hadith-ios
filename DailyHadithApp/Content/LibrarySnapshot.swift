import Foundation

struct LibrarySnapshot: Equatable {
    let hadiths: [AudioHadith]
    let themeCounts: [String: Int]

    private let byID: [AudioHadith.ID: AudioHadith]
    private let indexByID: [AudioHadith.ID: Int]
    private let hadithsByThemeID: [String: [AudioHadith]]
    private let searchTextByID: [AudioHadith.ID: String]

    init(hadiths: [AudioHadith]) throws {
        let ordered = hadiths.sorted { lhs, rhs in
            lhs.sequence < rhs.sequence
        }
        let ids = ordered.map(\.id)
        guard Set(ids).count == ids.count else {
            throw HadithRepositoryError.duplicateIDs
        }
        self.hadiths = ordered
        self.byID = Dictionary(uniqueKeysWithValues: ordered.map { ($0.id, $0) })
        self.indexByID = Dictionary(uniqueKeysWithValues: ordered.enumerated().map { ($0.element.id, $0.offset) })
        self.themeCounts = Dictionary(grouping: ordered.compactMap(\.primaryThemeID), by: { $0 })
            .mapValues(\.count)

        var groupedHadiths: [String: [AudioHadith]] = [:]
        for hadith in ordered {
            for themeID in hadith.allThemeIDs {
                groupedHadiths[themeID, default: []].append(hadith)
            }
        }
        self.hadithsByThemeID = groupedHadiths
        self.searchTextByID = Dictionary(
            uniqueKeysWithValues: ordered.map { hadith in
                (hadith.id, hadith.searchableText)
            }
        )
    }

    var count: Int {
        hadiths.count
    }

    var first: AudioHadith? {
        hadiths.first
    }

    func hadith(id: AudioHadith.ID?) -> AudioHadith? {
        guard let id else { return nil }
        return byID[id]
    }

    func index(of id: AudioHadith.ID) -> Int? {
        indexByID[id]
    }

    func hadith(after id: AudioHadith.ID) -> AudioHadith? {
        guard !hadiths.isEmpty, let index = indexByID[id] else { return nil }
        return hadiths[(index + 1) % hadiths.count]
    }

    func hadith(before id: AudioHadith.ID) -> AudioHadith? {
        guard !hadiths.isEmpty, let index = indexByID[id] else { return nil }
        let previousIndex = index == 0 ? hadiths.count - 1 : index - 1
        return hadiths[previousIndex]
    }

    func hadiths(forTheme themeID: HadithTheme.ID) -> [AudioHadith] {
        hadithsByThemeID[themeID] ?? []
    }

    func search(_ candidates: [AudioHadith], matching query: String) -> [AudioHadith] {
        let normalizedQuery = query.normalizedForHadithSearch
        guard !normalizedQuery.isEmpty else { return candidates }
        return candidates.filter { hadith in
            searchTextByID[hadith.id]?.contains(normalizedQuery) == true
        }
    }
}

private extension AudioHadith {
    var searchableText: String {
        [
            title,
            titleUrdu,
            summary,
            translation
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        .normalizedForHadithSearch
    }
}

private extension String {
    var normalizedForHadithSearch: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
