import Foundation

struct ListeningProgress: Codable, Equatable {
    var currentHadithID: AudioHadith.ID?
    var listenedHadithIDs: Set<AudioHadith.ID>
    var playbackPositions: [AudioHadith.ID: TimeInterval]
    var translationNoticeAcknowledged: Bool

    static let empty = ListeningProgress(
        currentHadithID: nil,
        listenedHadithIDs: [],
        playbackPositions: [:],
        translationNoticeAcknowledged: false
    )
}
