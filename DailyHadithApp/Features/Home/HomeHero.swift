import SwiftUI

struct HomeHero: View {
    private let heroHeight: CGFloat = 362

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
                Text("السلام عليكم")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(AppTheme.ink.opacity(0.66))
                    .environment(\.layoutDirection, .rightToLeft)

                Text("Daily Hadith")
                    .font(.system(size: 44, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("May Allah bless your day")
                    .font(.body)
                    .foregroundStyle(AppTheme.ink.opacity(0.62))
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 116)
        }
        .frame(height: heroHeight)
    }

    private var heroReadabilityWash: some View {
        LinearGradient(
            stops: [
                .init(color: Color.white.opacity(0.82), location: 0),
                .init(color: Color.white.opacity(0.66), location: 0.34),
                .init(color: Color.white.opacity(0.20), location: 0.62),
                .init(color: Color.white.opacity(0.02), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var heroBottomFade: some View {
        LinearGradient(
            stops: [
                .init(color: Color.clear, location: 0),
                .init(color: Color.clear, location: 0.56),
                .init(color: AppTheme.warmBackground.opacity(0.30), location: 0.78),
                .init(color: AppTheme.warmBackground.opacity(0.96), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HomeHero()
}
