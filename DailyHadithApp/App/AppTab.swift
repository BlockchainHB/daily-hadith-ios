import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case home
    case library
    case settings

    var title: String {
        switch self {
        case .home: "Today"
        case .library: "Library"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .library: "book.closed.fill"
        case .settings: "gearshape.fill"
        }
    }

    @ViewBuilder
    var label: some View {
        Label(title, systemImage: symbolName)
    }
}
