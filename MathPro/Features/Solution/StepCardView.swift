import SwiftUI

struct StepCardView: View {
    let step: SolutionStep
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.md) {
                    // Step number badge
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primarySoft)
                            .frame(width: 32, height: 32)
                        Text("\(step.stepNumber)")
                            .font(AppTheme.Fonts.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.primary)
                    }

                    Text(step.title)
                        .font(AppTheme.Fonts.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
            }

            // Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Divider()
                        .background(AppTheme.Colors.divider)

                    if let expr = step.expression, !expr.isEmpty {
                        Text(expr)
                            .font(AppTheme.Fonts.math)
                            .foregroundStyle(AppTheme.Colors.primary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.top, AppTheme.Spacing.sm)
                    }

                    Text(step.explanation)
                        .font(AppTheme.Fonts.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.bottom, AppTheme.Spacing.md)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cardStyle()
        .onAppear {
            // İlk adımı otomatik aç
            if step.stepNumber == 1 { isExpanded = true }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StepCardView(step: SolutionStep(
            stepNumber: 1,
            title: "Denklemi yeniden yaz",
            explanation: "2x + 3 = 7 denklemini çözmek için önce sabit terimi sola alıyoruz.",
            expression: "2x + 3 = 7"
        ))
        StepCardView(step: SolutionStep(
            stepNumber: 2,
            title: "Sabiti taşı",
            explanation: "Her iki taraftan 3 çıkarıyoruz.",
            expression: "2x = 7 - 3 = 4"
        ))
    }
    .padding()
    .background(AppTheme.Colors.background)
    .preferredColorScheme(.dark)
}
