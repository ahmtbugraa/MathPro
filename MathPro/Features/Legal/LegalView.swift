import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(AppTheme.Fonts.largeTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Last updated: March 25, 2026")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Group {
                        sectionTitle("1. Information We Collect")
                        sectionBody("""
                        MathPro collects minimal data to provide its core functionality:

                        • **Photos**: When you take or select a photo, it is processed to solve the math problem. Photos are sent to our AI provider for analysis and are not stored on our servers.
                        • **Usage Data**: We track basic usage metrics (number of solves) locally on your device to manage free trial limits.
                        • **Purchase Information**: If you subscribe to Premium, purchase data is handled by Apple and RevenueCat. We do not have access to your payment details.
                        • **Education Level**: Your selected education level is stored locally on your device to customize AI responses.
                        """)

                        sectionTitle("2. How We Use Information")
                        sectionBody("""
                        • To solve math problems from your photos using AI
                        • To manage your subscription status
                        • To adapt explanation complexity to your education level
                        • To improve app performance and user experience
                        """)

                        sectionTitle("3. Data Storage")
                        sectionBody("""
                        • Solution history is stored locally on your device using SwiftData.
                        • No personal data is stored on external servers.
                        • Photos are processed in real-time and not permanently stored.
                        """)

                        sectionTitle("4. Third-Party Services")
                        sectionBody("""
                        • **AI Provider**: Processes math problem images. Subject to the provider's privacy policy.
                        • **RevenueCat**: Manages subscriptions. Subject to RevenueCat's privacy policy.
                        • **Apple**: Handles all payments through the App Store.
                        """)

                        sectionTitle("5. Children's Privacy")
                        sectionBody("MathPro does not knowingly collect personal information from children under 13. The app is designed for educational use across all age groups.")

                        sectionTitle("6. Your Rights")
                        sectionBody("You can delete all your local data at any time from Settings > Clear All History. Uninstalling the app removes all locally stored data.")

                        sectionTitle("7. Contact")
                        sectionBody("For questions about this privacy policy, contact us at: ahmetbugrakacdi@gmail.com")
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Fonts.headline)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .padding(.top, 8)
    }

    private func sectionBody(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func sectionBody(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Terms of Use View
struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Use")
                        .font(AppTheme.Fonts.largeTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Last updated: March 25, 2026")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Group {
                        sectionTitle("1. Acceptance of Terms")
                        sectionBody("By using MathPro, you agree to these Terms of Use. If you do not agree, please do not use the app.")

                        sectionTitle("2. Description of Service")
                        sectionBody("MathPro is an AI-powered math solving app that analyzes photos of math problems and provides step-by-step solutions. The app is intended for educational purposes only.")

                        sectionTitle("3. Subscriptions")
                        sectionBody("""
                        • MathPro offers auto-renewable subscriptions (Weekly and Annual plans).
                        • Payment is charged to your Apple ID account at confirmation of purchase.
                        • Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.
                        • You can manage and cancel subscriptions in your Apple ID Account Settings.
                        • Free trial: 1 math solve is available for free before subscription is required.
                        """)

                        sectionTitle("4. Accuracy Disclaimer")
                        sectionBody("MathPro uses AI to solve math problems. While we strive for accuracy, solutions may occasionally contain errors. Always verify important results independently. MathPro should not be used as the sole source for exam answers or critical calculations.")

                        sectionTitle("5. Acceptable Use")
                        sectionBody("""
                        You agree not to:
                        • Use the app for academic dishonesty or cheating on exams
                        • Attempt to reverse-engineer or tamper with the app
                        • Use the app for any illegal purpose
                        • Share your subscription with others
                        """)

                        sectionTitle("6. Intellectual Property")
                        sectionBody("MathPro and its content are protected by copyright and intellectual property laws. You may not copy, modify, or distribute the app or its content.")

                        sectionTitle("7. Limitation of Liability")
                        sectionBody("MathPro is provided \"as is\" without warranties. We are not liable for any damages arising from use of the app, including incorrect solutions.")

                        sectionTitle("8. Changes to Terms")
                        sectionBody("We may update these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.")

                        sectionTitle("9. Contact")
                        sectionBody("For questions about these terms, contact us at: ahmetbugrakacdi@gmail.com")
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Fonts.headline)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .padding(.top, 8)
    }

    private func sectionBody(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Privacy") { PrivacyPolicyView() }
#Preview("Terms") { TermsOfUseView() }
