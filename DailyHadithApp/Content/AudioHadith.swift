import Foundation

struct AudioHadith: Identifiable, Hashable, Decodable {
    typealias ID = String

    let id: ID
    let sequence: Int
    let audioFileName: String
    let durationSeconds: TimeInterval
    let title: String
    let titleUrdu: String?
    let primaryThemeID: String?
    let secondaryThemeIDs: [String]?
    let summary: String
    let translation: String
    let uncertaintyNote: String
    let reviewStatus: String
    let reviewConfidence: String
    let reviewIssues: [String]

    var displaySequence: String {
        String(format: "%03d", sequence)
    }

    var audioStem: String {
        (audioFileName as NSString).deletingPathExtension
    }

    func audioURL(in bundle: Bundle = .main) throws -> URL {
        guard let url = bundle.url(
            forResource: audioStem,
            withExtension: "m4a",
            subdirectory: "Audio"
        ) else {
            throw HadithRepositoryError.missingAudio(audioFileName)
        }
        return url
    }

    var durationText: String {
        DurationFormatter.format(durationSeconds)
    }

    var hasManualReviewNote: Bool {
        reviewStatus == "needs_manual_review" || !reviewIssues.isEmpty || !uncertaintyNote.isEmpty
    }

    var allThemeIDs: [String] {
        var ids: [String] = []
        if let primaryThemeID {
            ids.append(primaryThemeID)
        }
        ids.append(contentsOf: secondaryThemeIDs ?? [])
        return Array(Set(ids))
    }
}
