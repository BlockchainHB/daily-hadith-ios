import SwiftUI

struct ManualCompletionMenu: View {
    let isListened: Bool
    let markListened: () -> Void
    let markUnlistened: () -> Void

    var body: some View {
        Menu {
            Button {
                isListened ? markUnlistened() : markListened()
            } label: {
                Label(isListened ? "Mark Unlistened" : "Mark Listened", systemImage: isListened ? "circle" : "checkmark.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .accessibilityLabel("More playback actions")
    }
}
