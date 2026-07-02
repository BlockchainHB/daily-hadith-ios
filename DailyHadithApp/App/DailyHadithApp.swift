import SwiftUI
import UIKit

@main
struct DailyHadithApp: App {
    init() {
        UIScrollView.appearance().bounces = false
        UIScrollView.appearance().alwaysBounceVertical = false
        UIScrollView.appearance().showsVerticalScrollIndicator = false
    }

    var body: some Scene {
        WindowGroup {
            RootAppView()
                .background(AppTheme.warmBackground.ignoresSafeArea())
        }
    }
}
