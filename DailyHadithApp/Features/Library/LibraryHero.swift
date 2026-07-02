import SwiftUI

struct LibraryHero: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let searchPrompt: String
    @Binding var searchText: String
    let onSearchSubmit: () -> Void

    private let heroHeight: CGFloat = 362

    init(
        eyebrow: String = "کتب خانہ",
        title: String = "Library",
        subtitle: String = "Your collection of hadith.",
        searchPrompt: String = "Search hadith",
        searchText: Binding<String>,
        onSearchSubmit: @escaping () -> Void = {}
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.searchPrompt = searchPrompt
        self._searchText = searchText
        self.onSearchSubmit = onSearchSubmit
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                Image("DailyHeader")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: heroHeight)
                    .clipped()
                    .saturation(1.04)
                    .contrast(1.02)
            }

            heroReadabilityWash

            heroBottomFade

            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow)
                    .font(.title3.weight(.regular))
                    .foregroundStyle(AppTheme.ink.opacity(0.66))
                    .environment(\.layoutDirection, .rightToLeft)

                Text(title)
                    .font(.system(size: 44, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink.opacity(0.62))

                searchField
                    .padding(.top, 14)
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 116)
        }
        .frame(height: heroHeight)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(AppTheme.ink.opacity(0.54))
                .accessibilityHidden(true)

            TextField(searchPrompt, text: $searchText)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
                .submitLabel(.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit(onSearchSubmit)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.34))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .glassSurface(cornerRadius: 21, interactive: true)
    }

    private var heroReadabilityWash: some View {
        LinearGradient(
            stops: [
                .init(color: AppTheme.heroWash.opacity(0.82), location: 0),
                .init(color: AppTheme.heroWash.opacity(0.62), location: 0.36),
                .init(color: AppTheme.heroWash.opacity(0.20), location: 0.64),
                .init(color: AppTheme.heroWash.opacity(0.02), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var heroBottomFade: some View {
        LinearGradient(
            stops: [
                .init(color: Color.clear, location: 0),
                .init(color: Color.clear, location: 0.28),
                .init(color: AppTheme.warmBackground.opacity(0.12), location: 0.52),
                .init(color: AppTheme.warmBackground.opacity(0.68), location: 0.82),
                .init(color: AppTheme.warmBackground.opacity(0.98), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    LibraryHero(searchText: .constant(""))
}
