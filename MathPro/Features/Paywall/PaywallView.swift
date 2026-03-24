import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    private var subscriptionService = SubscriptionService.shared

    @State private var selectedPlan: PlanType = .annual
    @State private var isProcessing = false
    @State private var showError = false
    @State private var showRestoreSuccess = false

    enum PlanType {
        case weekly, annual
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        featuresSection
                        planSection
                        ctaSection
                        legalSection
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert(String(localized: "Error"), isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(subscriptionService.errorMessage ?? String(localized: "An error occurred"))
        }
        .alert(String(localized: "Restored!"), isPresented: $showRestoreSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text(String(localized: "Your subscription has been restored."))
        }
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
            featureRow(icon: "infinity",               text: String(localized: "Unlimited daily solves"))
            featureRow(icon: "list.number",            text: String(localized: "Detailed step-by-step explanation"))
            featureRow(icon: "clock.arrow.circlepath", text: String(localized: "Unlimited history"))
            featureRow(icon: "ipad.and.iphone",        text: String(localized: "Works on all devices"))
            featureRow(icon: "bolt.fill",              text: String(localized: "Priority AI response time"))
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
            // Weekly plan
            if let pkg = subscriptionService.weeklyPackage {
                planCard(
                    type: .weekly,
                    title: pkg.hasFreeTrial
                        ? (pkg.trialDurationText ?? String(localized: "Free Trial"))
                        : String(localized: "Weekly"),
                    price: pkg.hasFreeTrial ? String(localized: "FREE") : pkg.localizedPrice,
                    subtitle: pkg.hasFreeTrial
                        ? String(localized: "then") + " " + pkg.localizedPrice + String(localized: "/ week")
                        : pkg.localizedPrice + String(localized: "/ week"),
                    badge: nil
                )
            }

            // Annual plan
            if let pkg = subscriptionService.annualPackage {
                planCard(
                    type: .annual,
                    title: String(localized: "Annual Plan"),
                    price: pkg.localizedPrice,
                    subtitle: pkg.localizedPrice + String(localized: "/ year"),
                    badge: String(localized: "MOST POPULAR")
                )
            }

            // Fallback if offerings not loaded yet
            if subscriptionService.weeklyPackage == nil && subscriptionService.annualPackage == nil {
                ProgressView()
                    .tint(AppTheme.Colors.primary)
                    .padding(AppTheme.Spacing.lg)
                    .onAppear {
                        Task { await subscriptionService.fetchOfferings() }
                    }
            }
        }
    }

    private func planCard(type: PlanType, title: String, price: String, subtitle: String, badge: String?) -> some View {
        Button {
            withAnimation(.spring(response: 0.25)) {
                selectedPlan = type
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(
                            selectedPlan == type ? AppTheme.Colors.primary : AppTheme.Colors.divider,
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    if selectedPlan == type {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(AppTheme.Fonts.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.primary)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Text(price)
                    .font(AppTheme.Fonts.title2)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            .padding(AppTheme.Spacing.md)
            .background(
                selectedPlan == type ? AppTheme.Colors.primarySoft : AppTheme.Colors.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        selectedPlan == type ? AppTheme.Colors.primary : Color.clear,
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
                    let pkg = selectedPlan == .weekly
                        ? subscriptionService.weeklyPackage
                        : subscriptionService.annualPackage
                    let hasFreeTrial = pkg?.hasFreeTrial == true && selectedPlan == .weekly
                    Text(hasFreeTrial
                         ? String(localized: "Try for Free")
                         : String(localized: "Subscribe Now"))
                }
            }
            .primaryButton()
            .disabled(isProcessing)

            Text("Cancel anytime from Settings")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.md) {
                Button(String(localized: "Restore Purchase")) { restorePurchase() }
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("•").foregroundStyle(AppTheme.Colors.textTertiary)
                Button(String(localized: "Privacy Policy")) {
                    if let url = URL(string: "https://mathpro.app/privacy") {
                        UIApplication.shared.open(url)
                    }
                }
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("•").foregroundStyle(AppTheme.Colors.textTertiary)
                Button(String(localized: "Terms of Use")) {
                    if let url = URL(string: "https://mathpro.app/terms") {
                        UIApplication.shared.open(url)
                    }
                }
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Actions
    private func purchase() {
        let package: Package?
        switch selectedPlan {
        case .weekly:  package = subscriptionService.weeklyPackage
        case .annual:  package = subscriptionService.annualPackage
        }

        guard let package else { return }

        isProcessing = true
        Task {
            let success = await subscriptionService.purchase(package: package)
            await MainActor.run {
                isProcessing = false
                if success { dismiss() }
                else if subscriptionService.errorMessage != nil { showError = true }
            }
        }
    }

    private func restorePurchase() {
        isProcessing = true
        Task {
            let restored = await subscriptionService.restore()
            await MainActor.run {
                isProcessing = false
                if restored {
                    showRestoreSuccess = true
                } else if subscriptionService.errorMessage != nil {
                    showError = true
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
