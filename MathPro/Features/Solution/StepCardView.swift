import SwiftUI

// MARK: - Timeline Step View (Notebook Style)
struct StepCardView: View {
    let step: SolutionStep
    let isLast: Bool

    init(step: SolutionStep, isLast: Bool = false) {
        self.step = step
        self.isLast = isLast
    }

    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline column
            timelineColumn

            // Content column
            contentColumn
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(step.stepNumber): \(step.title). \(step.explanation)")
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(step.stepNumber - 1) * 0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Timeline Column
    private var timelineColumn: some View {
        VStack(spacing: 0) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 32, height: 32)

                Text("\(step.stepNumber)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
            }

            // Connecting line
            if !isLast {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary.opacity(0.6), AppTheme.Colors.primary.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 32)
        .padding(.trailing, 14)
    }

    // MARK: - Content Column
    private var contentColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(step.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            // Explanation
            Text(step.explanation)
                .font(.system(size: 14.5, weight: .regular))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            // Math expression (KaTeX rendered)
            if let expr = step.expression, !expr.isEmpty {
                DisplayMathView(latex: expr, fontSize: 17)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.Colors.primary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(AppTheme.Colors.primary.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.bottom, isLast ? 0 : 24)
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 0) {
            StepCardView(
                step: SolutionStep(
                    stepNumber: 1,
                    title: "Denklemi yeniden yaz",
                    explanation: "2x + 3 = 7 denklemini cozmek icin once sabit terimi sola aliyoruz.",
                    expression: "2x + 3 = 7"
                ),
                isLast: false
            )
            StepCardView(
                step: SolutionStep(
                    stepNumber: 2,
                    title: "Sabiti tasi",
                    explanation: "Her iki taraftan 3 cikariyoruz.",
                    expression: "2x = 7 - 3 = 4"
                ),
                isLast: false
            )
            StepCardView(
                step: SolutionStep(
                    stepNumber: 3,
                    title: "x'i bul",
                    explanation: "Her iki tarafi 2'ye boluyoruz.",
                    expression: "x = \\frac{4}{2} = 2"
                ),
                isLast: true
            )
        }
        .padding(20)
    }
    .background(AppTheme.Colors.background)
    .preferredColorScheme(.dark)
}
