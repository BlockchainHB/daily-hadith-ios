import SwiftUI

struct SettingsView: View {
    let loadState: LibraryLoadState
    @ObservedObject var playbackStore: PlaybackStore
    @ObservedObject var progressStore: ListeningProgressStore

    @State private var resetConfirmation: ResetProgressConfirmation?

    var body: some View {
        Form {
            CharitySection()
            PlaybackSettingsSection {
                resetConfirmation = .allProgress
            }
            AboutSection(
                libraryCount: libraryCount,
                translationNoticeAcknowledged: progressStore.translationNoticeAcknowledged,
                acknowledgeTranslationNotice: progressStore.acknowledgeTranslationNotice
            )
            DedicationSection()
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.warmBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Reset listening progress?",
            isPresented: Binding(
                get: { resetConfirmation != nil },
                set: { isPresented in
                    if !isPresented {
                        resetConfirmation = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                progressStore.resetAllProgress(snapshot: snapshot)
                playbackStore.stop()
                if let first = snapshot?.first {
                    playbackStore.load(hadith: first)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears listened items and saved playback positions.")
        }
    }

    private var snapshot: LibrarySnapshot? {
        if case .loaded(let snapshot) = loadState {
            return snapshot
        }
        return nil
    }

    private var libraryCount: Int {
        snapshot?.count ?? 0
    }
}

enum ResetProgressConfirmation: Identifiable {
    case allProgress

    var id: String { "allProgress" }
}

#Preview("Settings") {
    SettingsView(
        loadState: .loaded(PreviewFixtures.snapshot),
        playbackStore: PlaybackStore(),
        progressStore: ListeningProgressStore(defaults: .preview)
    )
}
