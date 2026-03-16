import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremium") private var isPremium = false

    @State private var selectedPlan: Plan = .annual
    @State private var isProcessing = false

    enum Plan: String, CaseIterable {
        case weekly  = "Weekly"
        case annual  = "Annual"

        var price: String {
            switch self {
            case .weekly: return "₺99"
            case .annual: return "₺499"
            }
        }

        var period: String {
            switch self {
            case .weekly: return "/ week"
            case .annual: return "/ year"
            }
        }

        var badge: String? {
            switch self {
            case .annual: return "MOST POPULAR"
            default:      return nil
            }
        }

        var monthlyEquivalent: String? {
            switch self {
            case .annual: return "≈ ₺42/month"
            default: return nil
            }
        }
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Feature list
                        featuresSection

                        // Plan picker
                        planSection

                        // CTA
                        ctaSection

                        // Legal
                        legalSection
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.md)

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("MathPro Premium")
                .font(AppTheme.Fonts.largeTitle)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Unlimited solves. Learn step by step.")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            featureRow(icon: "infinity",                   text: "Unlimited daily solves")
            featureRow(icon: "list.number",                text: "Detailed step-by-step explanation")
            featureRow(icon: "clock.arrow.circlepath",     text: "Unlimited history")
            featureRow(icon: "ipad.and.iphone",            text: "Works on all devices")
            featureRow(icon: "bolt.fill",                  text: "Priority AI response time")
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(AppTheme.Colors.primary)
                .frame(width: 24)
            Text(text)
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Spacer()
            Image(systemName: "checkmark")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.primary)
        }
    }

    // MARK: - Plans
    private var planSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(Plan.allCases, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: Plan) -> some View {
        Button {
            withAnimation(.spring(response: 0.25)) {
                selectedPlan = plan
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(
                            selectedPlan == plan ? AppTheme.Colors.primary : AppTheme.Colors.divider,
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    if selectedPlan == plan {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(LocalizedStringKey(plan.rawValue))
                            .font(AppTheme.Fonts.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        if let badge = plan.badge {
                            Text(LocalizedStringKey(badge))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.primary)
                                .clipShape(Capsule())
                        }
                    }
                    if let eq = plan.monthlyEquivalent {
                        Text(eq)
                            .font(AppTheme.Fonts.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(plan.price)
                        .font(AppTheme.Fonts.title2)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(LocalizedStringKey(plan.period))
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                selectedPlan == plan
                    ? AppTheme.Colors.primarySoft
                    : AppTheme.Colors.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        selectedPlan == plan ? AppTheme.Colors.primary : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }

    // MARK: - CTA
    private var ctaSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Button {
                purchase()
            } label: {
                if isProcessing {
                    ProgressView().tint(.black)
                } else {
                    Text("Start Now — \(selectedPlan.price)")
                }
            }
            .primaryButton()
            .disabled(isProcessing)

            Text("Try 3 days free, cancel anytime")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.md) {
                Button("Restore Purchase") {}
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("•").foregroundStyle(AppTheme.Colors.textTertiary)
                Button("Privacy Policy") {}
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("•").foregroundStyle(AppTheme.Colors.textTertiary)
                Button("Terms of Use") {}
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    private func purchase() {
        isProcessing = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run {
                isProcessing = false
                dismiss()
            }
        }
    }
}

#Preview {
    PaywallView()
}
