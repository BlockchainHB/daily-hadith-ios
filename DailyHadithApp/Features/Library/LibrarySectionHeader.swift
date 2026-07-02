import SwiftUI

struct LibrarySectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.ink)

            Spacer(minLength: 12)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.screenPadding)
    }
}
