import AVFoundation
import Foundation

@MainActor
final class PlaybackStore: ObservableObject {
    @Published private(set) var currentHadithID: AudioHadith.ID?
    @Published private(set) var state: PlaybackState = .stopped
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var completedHadithID: AudioHadith.ID?

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var completionObserver: NSObjectProtocol?

    var shouldShowMiniPlayer: Bool {
        state.isActive
    }

    deinit {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        if let completionObserver {
            NotificationCenter.default.removeObserver(completionObserver)
        }
    }

    func load(hadith: AudioHadith, savedPosition: TimeInterval = 0, autoplay: Bool = false) {
        if currentHadithID == hadith.id, player != nil {
            if autoplay {
                play()
            }
            return
        }

        state = .loading
        completedHadithID = nil
        currentHadithID = hadith.id
        duration = hadith.durationSeconds
        elapsed = min(max(savedPosition, 0), max(hadith.durationSeconds - 1, 0))

        do {
            let url = try hadith.audioURL()
            try configureAudioSession()
            replacePlayerItem(url: url, initialPosition: elapsed)
            state = autoplay ? .playing : .ready
            if autoplay {
                player?.play()
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func currentHadith(in snapshot: LibrarySnapshot) -> AudioHadith? {
        snapshot.hadith(id: currentHadithID)
    }

    func play() {
        guard player != nil else { return }
        state = .playing
        player?.play()
    }

    func pause() {
        guard player != nil else { return }
        player?.pause()
        state = .paused
    }

    func togglePlay() {
        state.isPlaying ? pause() : play()
    }

    func seek(to seconds: TimeInterval) {
        guard let player else { return }
        state = .seeking
        let clamped = min(max(seconds, 0), max(duration, 0))
        let wasPlaying = player.rate > 0
        player.seek(to: CMTime(seconds: clamped, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                self?.elapsed = clamped
                self?.state = wasPlaying ? .playing : .paused
                if wasPlaying {
                    self?.player?.play()
                }
            }
        }
    }

    func skip(by seconds: TimeInterval) {
        seek(to: elapsed + seconds)
    }

    func stop() {
        player?.pause()
        player = nil
        state = .stopped
        elapsed = 0
        duration = 0
        currentHadithID = nil
    }

    private func replacePlayerItem(url: URL, initialPosition: TimeInterval) {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        if let completionObserver {
            NotificationCenter.default.removeObserver(completionObserver)
            self.completionObserver = nil
        }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        if initialPosition > 0 {
            player?.seek(to: CMTime(seconds: initialPosition, preferredTimescale: 600))
        }

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.elapsed = time.seconds.isFinite ? time.seconds : 0
            }
        }

        completionObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.elapsed = self.duration
                self.state = .paused
                self.completedHadithID = self.currentHadithID
            }
        }
    }

    private func configureAudioSession() throws {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            throw PlaybackSetupError.audioSessionUnavailable
        }
        #endif
    }
}

private enum PlaybackSetupError: LocalizedError {
    case audioSessionUnavailable

    var errorDescription: String? {
        switch self {
        case .audioSessionUnavailable:
            "Audio session could not start."
        }
    }
}
