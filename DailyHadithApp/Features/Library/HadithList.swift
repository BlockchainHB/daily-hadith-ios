import SwiftUI

struct HadithList: View {
    let hadiths: [AudioHadith]
    let totalCount: Int
    let currentHadithID: AudioHadith.ID?
    let playingHadithID: AudioHadith.ID?
    let isListened: (AudioHadith.ID) -> Bool
    let select: (AudioHadith) -> Void

    var body: some View {
        if hadiths.isEmpty {
            UnavailableStateView(
                title: "No Results",
                systemName: "magnifyingglass",
                message: "Try a different search."
            )
        } else {
            List(hadiths) { hadith in
                Button {
                    select(hadith)
                } label: {
                    HadithRow(
                        hadith: hadith,
                        totalCount: totalCount,
                        isCurrent: hadith.id == currentHadithID,
                        isPlaying: hadith.id == playingHadithID,
                        isListened: isListened(hadith.id)
                    )
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 0, leading: AppTheme.screenPadding, bottom: 0, trailing: AppTheme.screenPadding))
                .listRowBackground(AppTheme.warmBackground)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppTheme.warmBackground)
        }
    }
}
