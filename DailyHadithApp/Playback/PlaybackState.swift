import Foundation

enum PlaybackState: Equatable {
    case stopped
    case loading
    case ready
    case playing
    case paused
    case seeking
    case failed(String)

    var isPlaying: Bool {
        if case .playing = self {
            return true
        }
        return false
    }

    var isActive: Bool {
        switch self {
        case .stopped:
            false
        case .loading, .ready, .playing, .paused, .seeking, .failed:
            true
        }
    }
}
