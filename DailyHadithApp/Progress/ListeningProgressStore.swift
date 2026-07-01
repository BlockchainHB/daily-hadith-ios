import Foundation

@MainActor
final class ListeningProgressStore: ObservableObject {
    @Published private(set) var progress: ListeningProgress

    private let defaults: UserDefaults
    private let storageKey = "dailyHadith.listeningProgress.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.progress = Self.loadProgress(defaults: defaults, key: storageKey)
    }

    var currentHadithID: AudioHadith.ID? {
        progress.currentHadithID
    }

    var listenedCount: Int {
        progress.listenedHadithIDs.count
    }

    var translationNoticeAcknowledged: Bool {
        progress.translationNoticeAcknowledged
    }

    func prepareForLibrary(_ snapshot: LibrarySnapshot) {
        let currentIsValid = snapshot.hadith(id: progress.currentHadithID) != nil
        if !currentIsValid {
            progress.currentHadithID = snapshot.first?.id
            save()
        }
    }

    func setCurrentHadith(_ id: AudioHadith.ID) {
        guard progress.currentHadithID != id else { return }
        progress.currentHadithID = id
        save()
    }

    func markListened(_ id: AudioHadith.ID) {
        progress.listenedHadithIDs.insert(id)
        progress.playbackPositions[id] = 0
        save()
    }

    func markUnlistened(_ id: AudioHadith.ID) {
        progress.listenedHadithIDs.remove(id)
        save()
    }

    func isListened(_ id: AudioHadith.ID) -> Bool {
        progress.listenedHadithIDs.contains(id)
    }

    func savePlaybackPosition(_ seconds: TimeInterval, for id: AudioHadith.ID) {
        guard seconds.isFinite, seconds >= 0 else { return }
        progress.playbackPositions[id] = seconds
        save()
    }

    func playbackPosition(for id: AudioHadith.ID) -> TimeInterval {
        progress.playbackPositions[id] ?? 0
    }

    func acknowledgeTranslationNotice() {
        guard !progress.translationNoticeAcknowledged else { return }
        progress.translationNoticeAcknowledged = true
        save()
    }

    func resetAllProgress(snapshot: LibrarySnapshot?) {
        progress = .empty
        if let first = snapshot?.first {
            progress.currentHadithID = first.id
        }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func loadProgress(defaults: UserDefaults, key: String) -> ListeningProgress {
        guard let data = defaults.data(forKey: key),
              let progress = try? JSONDecoder().decode(ListeningProgress.self, from: data) else {
            return .empty
        }
        return progress
    }
}
