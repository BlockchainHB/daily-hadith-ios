import AVFoundation
import Foundation
import MediaPlayer
import UIKit

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
    private var interruptionObserver: NSObjectProtocol?
    private var resumeAfterInterruption = false
    private var currentHadith: AudioHadith?
    private var remoteCommandTargets: [(MPRemoteCommand, Any)] = []
    private static let nowPlayingArtwork: MPMediaItemArtwork? = {
        guard let image = UIImage(named: "NowPlayingArtwork") else { return nil }
        return MPMediaItemArtwork(boundsSize: image.size) { requestedSize in
            guard requestedSize.width > 0, requestedSize.height > 0 else { return image }
            return UIGraphicsImageRenderer(size: requestedSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: requestedSize))
            }
        }
    }()

    init() {
        configureRemoteCommands()
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleAudioInterruption(notification)
            }
        }
    }

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
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
        for (command, target) in remoteCommandTargets {
            command.removeTarget(target)
        }
    }

    func load(hadith: AudioHadith, savedPosition: TimeInterval = 0, autoplay: Bool = false) {
        if currentHadithID == hadith.id, player != nil {
            if autoplay {
                play()
            }
            return
        }

        discardPlayer()
        clearNowPlaying()
        state = .loading
        resumeAfterInterruption = false
        completedHadithID = nil
        currentHadithID = hadith.id
        currentHadith = hadith
        duration = hadith.durationSeconds
        elapsed = min(max(savedPosition, 0), max(hadith.durationSeconds - 1, 0))

        do {
            let url = try hadith.audioURL()
            replacePlayerItem(url: url, initialPosition: elapsed)
            state = .ready
            if autoplay {
                play()
            } else {
                clearNowPlaying()
                deactivateAudioSession()
            }
        } catch {
            state = .failed(error.localizedDescription)
            clearNowPlaying()
            deactivateAudioSession()
        }
    }

    func currentHadith(in snapshot: LibrarySnapshot) -> AudioHadith? {
        snapshot.hadith(id: currentHadithID)
    }

    func play() {
        guard player != nil else { return }
        do {
            try configureAudioSession()
            player?.play()
            state = .playing
            updateNowPlaying()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func pause() {
        guard player != nil else { return }
        player?.pause()
        state = .paused
        updateNowPlaying()
        deactivateAudioSession()
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
                guard let self, self.player === player else { return }
                self.elapsed = clamped
                self.state = wasPlaying ? .playing : .paused
                if wasPlaying {
                    player.play()
                }
                self.updateNowPlaying()
            }
        }
    }

    func skip(by seconds: TimeInterval) {
        seek(to: elapsed + seconds)
    }

    func stop() {
        discardPlayer()
        state = .stopped
        elapsed = 0
        duration = 0
        currentHadithID = nil
        currentHadith = nil
        resumeAfterInterruption = false
        clearNowPlaying()
        deactivateAudioSession()
    }

    private func replacePlayerItem(url: URL, initialPosition: TimeInterval) {
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer

        if initialPosition > 0 {
            newPlayer.seek(to: CMTime(seconds: initialPosition, preferredTimescale: 600))
        }

        timeObserver = newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self, weak newPlayer] time in
            Task { @MainActor in
                guard let self, let newPlayer, self.player === newPlayer else { return }
                self.elapsed = time.seconds.isFinite ? time.seconds : 0
            }
        }

        completionObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.player?.currentItem === item else { return }
                self.elapsed = self.duration
                self.state = .paused
                self.updateNowPlaying()
                self.deactivateAudioSession()
                self.completedHadithID = self.currentHadithID
            }
        }
    }

    private func discardPlayer() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        if let completionObserver {
            NotificationCenter.default.removeObserver(completionObserver)
            self.completionObserver = nil
        }
        player?.pause()
        player = nil
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

    private func deactivateAudioSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    private func handleAudioInterruption(_ notification: Notification) {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            resumeAfterInterruption = state.isPlaying
            if state.isPlaying {
                pause()
            }
        case .ended:
            let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let shouldResume = AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume)
            if resumeAfterInterruption && shouldResume {
                play()
            }
            resumeAfterInterruption = false
        @unknown default:
            break
        }
    }

    private func updateNowPlaying() {
        guard let hadith = currentHadith else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: hadith.title,
            MPMediaItemPropertyArtist: "Daily Hadith",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: state.isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
        if let artwork = Self.nowPlayingArtwork {
            info[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func configureRemoteCommands() {
        let commands = MPRemoteCommandCenter.shared()
        commands.playCommand.isEnabled = true
        commands.pauseCommand.isEnabled = true
        commands.togglePlayPauseCommand.isEnabled = true
        commands.skipBackwardCommand.isEnabled = true
        commands.skipForwardCommand.isEnabled = true
        commands.skipBackwardCommand.preferredIntervals = [15]
        commands.skipForwardCommand.preferredIntervals = [15]
        commands.changePlaybackPositionCommand.isEnabled = true

        register(commands.playCommand) { store, _ in store.play() }
        register(commands.pauseCommand) { store, _ in store.pause() }
        register(commands.togglePlayPauseCommand) { store, _ in store.togglePlay() }
        register(commands.skipBackwardCommand) { store, _ in store.skip(by: -15) }
        register(commands.skipForwardCommand) { store, _ in store.skip(by: 15) }
        register(commands.changePlaybackPositionCommand) { store, event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return }
            store.seek(to: event.positionTime)
        }
    }

    private func register(
        _ command: MPRemoteCommand,
        action: @escaping @MainActor (PlaybackStore, MPRemoteCommandEvent) -> Void
    ) {
        let target = command.addTarget { [weak self] event in
            Task { @MainActor [weak self] in
                guard let self, self.player != nil else { return }
                action(self, event)
            }
            return .success
        }
        remoteCommandTargets.append((command, target))
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
