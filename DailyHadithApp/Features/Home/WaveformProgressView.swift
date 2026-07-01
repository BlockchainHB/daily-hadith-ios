import SwiftUI

struct WaveformProgressView: View {
    let progress: Double

    private let bars: [CGFloat] = [
        0.30, 0.58, 0.80, 0.46, 0.72, 0.92, 0.54, 0.38,
        0.76, 0.60, 0.44, 0.88, 0.68, 0.50, 0.34, 0.64,
        0.84, 0.52, 0.74, 0.42, 0.32, 0.58, 0.70, 0.48,
        0.78, 0.56, 0.36, 0.66, 0.90, 0.62, 0.46, 0.72,
        0.82, 0.54, 0.40, 0.68
    ]

    var body: some View {
        Canvas { context, size in
            let clampedProgress = min(max(progress, 0), 1)
            let barWidth = min(3.4, max(2.2, size.width / 82))
            let totalBarWidth = barWidth * CGFloat(bars.count)
            let spacing = max(2, (size.width - totalBarWidth) / CGFloat(max(bars.count - 1, 1)))
            let activeWidth = size.width * clampedProgress

            for (index, value) in bars.enumerated() {
                let x = CGFloat(index) * (barWidth + spacing)
                let height = max(9, size.height * value)
                let y = (size.height - height) / 2
                let rect = CGRect(x: x, y: y, width: barWidth, height: height)
                let color = x <= activeWidth ? AppTheme.ink : AppTheme.ink.opacity(0.12)

                context.fill(
                    Path(roundedRect: rect, cornerRadius: barWidth / 2),
                    with: .color(color)
                )
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    WaveformProgressView(progress: 0.38)
        .frame(width: 240, height: 48)
        .padding()
}
