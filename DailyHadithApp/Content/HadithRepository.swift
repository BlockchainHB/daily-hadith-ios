import Foundation

struct HadithRepository {
    private let bundle: Bundle
    private let manifestName: String

    init(bundle: Bundle = .main, manifestName: String = "hadiths.reviewed") {
        self.bundle = bundle
        self.manifestName = manifestName
    }

    func loadSnapshot() async throws -> LibrarySnapshot {
        try await Task.detached(priority: .userInitiated) {
            guard let url = bundle.url(forResource: manifestName, withExtension: "json") else {
                throw HadithRepositoryError.missingManifest
            }
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let hadiths = try decoder.decode([AudioHadith].self, from: data)
            guard !hadiths.isEmpty else {
                throw HadithRepositoryError.emptyManifest
            }
            return try LibrarySnapshot(hadiths: hadiths)
        }.value
    }
}

enum HadithRepositoryError: LocalizedError, Equatable {
    case missingManifest
    case emptyManifest
    case duplicateIDs
    case missingAudio(String)

    var errorDescription: String? {
        switch self {
        case .missingManifest:
            "Hadith library manifest was not found."
        case .emptyManifest:
            "Hadith library is empty."
        case .duplicateIDs:
            "Hadith library contains duplicate IDs."
        case .missingAudio(let fileName):
            "Audio file is missing: \(fileName)."
        }
    }
}
