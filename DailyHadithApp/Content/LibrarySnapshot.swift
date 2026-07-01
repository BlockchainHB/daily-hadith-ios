import Foundation

struct LibrarySnapshot: Equatable {
    let hadiths: [AudioHadith]

    private let byID: [AudioHadith.ID: AudioHadith]
    private let indexByID: [AudioHadith.ID: Int]

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
}
