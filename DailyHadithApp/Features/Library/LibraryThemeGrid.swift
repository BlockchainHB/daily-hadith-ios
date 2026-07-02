import SwiftUI

struct LibraryThemeGrid: View {
    let themeCounts: [String: Int]
    let selectTheme: (HadithTheme) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        themeGrid
            .padding(.horizontal, AppTheme.screenPadding)
    }

    @ViewBuilder
    private var themeGrid: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 10) {
                gridContent
            }
        } else {
            gridContent
        }
    }

    private var gridContent: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(ThemeCatalog.all) { theme in
                Button {
                    selectTheme(theme)
                } label: {
                    ThemeCard(theme: theme, count: themeCounts[theme.id, default: 0])
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ThemeCard: View {
    let theme: HadithTheme
    let count: Int

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: theme.symbolName)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppTheme.mutedGold.opacity(0.92))
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

            Text(theme.title)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .frame(height: 72)
        .glassSurface(cornerRadius: 20)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityLabel("\(theme.title), \(count) hadiths")
    }
}
