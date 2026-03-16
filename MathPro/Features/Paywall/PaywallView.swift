import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremium") private var isPremium = false

    @State private var selectedPlan: Plan = .annual
    @State private var isProcessing = false

    enum Plan: String, CaseIterable {
        case weekly  = "Haftalık"
        case annual  = "Yıllık"
        case lifetime = "Ömür Boyu"

        var price: String {
            switch self {
            case .weekly:   return "₺99"
            case .annual:   return "₺499"
            case .lifetime: return "₺999"
            }
        }

        var period: String {
            switch self {
            case .weekly:   return "/ hafta"
            case .annual:   return "/ yıl"
            case .lifetime: return "tek seferlik"
            }
        }

        var badge: String? {
            switch self {
            case .annual:   return "EN POPÜLER"
            case .lifetime: return "EN İYİ DEĞER"
            default:        return nil
            }
        }

        var monthlyEquivalent: String? {
            switch self {
            case .annual: return "≈ ₺42/ay"
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

            Text("Sınırsız çözüm. Adım adım öğren.")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            featureRow(icon: "infinity", text: "Sınırsız günlük çözüm")
            featureRow(icon: "list.number",    text: "Adım adım detaylı açıklama")
            featureRow(icon: "clock.arrow.circlepath", text: "Sınırsız geçmiş")
            featureRow(icon: "ipad.and.iphone", text: "Tüm cihazlarda çalışır")
            featureRow(icon: "bolt.fill",       text: "Öncelikli AI yanıt süresi")
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
                        Text(plan.rawValue)
                            .font(AppTheme.Fonts.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        if let badge = plan.badge {
                            Text(badge)
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
                    Text(plan.period)
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
                    Text("Şimdi Başla — \(selectedPlan.price)")
                }
            }
            .primaryButton()
            .disabled(isProcessing)

            Text("3 gün ücretsiz dene, istediğin zaman iptal et")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.md) {
                Button("Satın Alımı Geri Yükle") {}
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("•").foregroundStyle(AppTheme.Colors.textTertiary)
                Button("Gizlilik Politikası") {}
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("•").foregroundStyle(AppTheme.Colors.textTertiary)
                Button("Kullanım Şartları") {}
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    private func purchase() {
        // Faz 2: RevenueCat entegrasyonu
        isProcessing = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run {
                isProcessing = false
                // isPremium = true  // RevenueCat onayladıktan sonra
                dismiss()
            }
        }
    }
}

#Preview {
    PaywallView()
}
