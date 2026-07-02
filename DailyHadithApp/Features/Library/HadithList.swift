import SwiftUI

struct HadithList: View {
    let hadiths: [AudioHadith]
    let totalCount: Int
    let isListened: (AudioHadith.ID) -> Bool
    let select: (AudioHadith) -> Void

    var body: some View {
        LazyVStack(spacing: 0) {
            if hadiths.isEmpty {
                UnavailableStateView(
                    title: "No Results",
                    systemName: "magnifyingglass",
                    message: "Try a different search."
                )
                .padding(.top, 40)
                .padding(.horizontal, AppTheme.screenPadding)
            } else {
                ForEach(hadiths.indices, id: \.self) { index in
                    let hadith = hadiths[index]

                    Button {
                        select(hadith)
                    } label: {
                        HadithRow(
                            hadith: hadith,
                            totalCount: totalCount,
                            isListened: isListened(hadith.id)
                        )
                    }
                    .buttonStyle(.plain)

                    if index < hadiths.index(before: hadiths.endIndex) {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
        }
        .background(AppTheme.warmBackground)
    }
}
