import SwiftUI

struct LoadingStateView: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String

    var body: some View {
        UnavailableStateView(
            title: "Library Unavailable",
            systemName: "exclamationmark.triangle",
            message: message
        )
    }
}

struct UnavailableStateView: View {
    let title: String
    let systemName: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
