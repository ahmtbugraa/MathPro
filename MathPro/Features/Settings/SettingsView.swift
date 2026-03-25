import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @AppStorage("isPremium")       private var isPremium = false
    @AppStorage("educationLevel")  private var educationLevel: String = EducationLevel.high.rawValue

    @Environment(\.modelContext) private var modelContext
    @Query private var records: [SolveRecord]

    @State private var showClearConfirm = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Premium Banner
                        if !isPremium { premiumBanner }

                        // Stats
                        statsCard

                        // Education Level
                        educationSection

                        // About
                        aboutSection

                        // Danger zone
                        dangerSection
                    }
                    .padding(AppTheme.Spacing.md)
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .preferredColorScheme(.dark)
    }

    // MARK: - Premium Banner
    private var premiumBanner: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)

                VStack(alignment: .leading, spacing: 2) {
                    Text("MathPro Premium")
                        .font(AppTheme.Fonts.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("Unlimited solves, step animations")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Text("Upgrade")
                    .font(AppTheme.Fonts.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.primary)
                    .clipShape(Capsule())
            }
            .padding(AppTheme.Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.12), AppTheme.Colors.surface],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
            )
        }
    }

    // MARK: - Stats
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("STATISTICS")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            HStack {
                statItem(value: "\(records.count)", label: String(localized: "Total Solves"))
                Divider().frame(height: 40).background(AppTheme.Colors.divider)
                statItem(
                    value: isPremium ? "Premium" : "Free",
                    label: String(localized: "Plan")
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(value)
                .font(AppTheme.Fonts.title2)
                .foregroundStyle(AppTheme.Colors.primary)
            Text(label)
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Education Level
    private var educationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("education_level_section")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            VStack(spacing: 0) {
                ForEach(Array(EducationLevel.allCases.enumerated()), id: \.element.id) { idx, level in
                    let isSelected = educationLevel == level.rawValue
                    Button {
                        withAnimation(.spring(response: 0.25)) {
                            educationLevel = level.rawValue
                            EducationLevel.save(level)
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Text(level.emoji)
                                .font(.title3)

                            Text(level.localizedName)
                                .font(AppTheme.Fonts.callout)
                                .foregroundStyle(AppTheme.Colors.textPrimary)

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.Colors.primary)
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(isSelected ? AppTheme.Colors.primarySoft : Color.clear)
                    }

                    if idx < EducationLevel.allCases.count - 1 {
                        Divider().padding(.leading, 52).background(AppTheme.Colors.divider)
                    }
                }
            }
            .cardStyle()

            Text("education_level_hint")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
    }

    // MARK: - About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("APP")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            VStack(spacing: 0) {
                settingsRow(icon: "star.fill",           color: .yellow,                   title: "Rate the App") {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
                Divider().padding(.leading, 52).background(AppTheme.Colors.divider)
                settingsRow(icon: "square.and.arrow.up", color: .blue,                     title: "Share with Friends") {
                    let text = String(localized: "share_watermark")
                    let url = URL(string: "https://apps.apple.com/app/mathpro/id6651818007")!
                    let av = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(av, animated: true)
                    }
                }
                Divider().padding(.leading, 52).background(AppTheme.Colors.divider)
                settingsRow(icon: "envelope.fill",       color: AppTheme.Colors.primary,   title: "Send Feedback") {
                    if let url = URL(string: "mailto:ahmetbugrakacdi@gmail.com?subject=MathPro%20Feedback") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .cardStyle()
        }
    }

    // MARK: - Danger Zone
    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("DATA")
                .font(AppTheme.Fonts.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            Button(role: .destructive) {
                showClearConfirm = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(AppTheme.Colors.error)
                    Text("Clear All History")
                        .font(AppTheme.Fonts.callout)
                        .foregroundStyle(AppTheme.Colors.error)
                    Spacer()
                    Text(String(format: NSLocalizedString("%d records", comment: ""), records.count))
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .padding(AppTheme.Spacing.md)
                .cardStyle()
            }
            .confirmationDialog("All history will be deleted", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    records.forEach { modelContext.delete($0) }
                }
            }
        }
    }

    private func settingsRow(icon: String, color: Color, title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.md)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: SolveRecord.self, inMemory: true)
}
