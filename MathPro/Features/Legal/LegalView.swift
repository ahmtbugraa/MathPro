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

                    Text("Effective Date: March 26, 2026")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Group {
                        sectionBody("MathPro (\"we,\" \"our,\" or \"the App\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard information when you use MathPro.")

                        sectionTitle("1. Information We Collect")
                        sectionBody("""
                        **Information You Provide:**
                        \u{2022} Photos of Math Problems: Processed by AI to generate solutions. Stored locally on your device in solution history.
                        \u{2022} Education Level: Stored locally on your device to customize explanation complexity.

                        **Automatically Collected:**
                        \u{2022} Usage Metrics: Daily/total solve counts stored locally on your device (UserDefaults).
                        \u{2022} Subscription Status: Managed by RevenueCat using an anonymized user ID.
                        \u{2022} Device Language: Read at runtime to provide localized responses; not stored.
                        """)

                        sectionTitle("2. What We Do NOT Collect")
                        highlightBox("""
                        \u{2022} We do not collect your name, email, or phone number.
                        \u{2022} We do not collect location data.
                        \u{2022} We do not use cookies or tracking pixels.
                        \u{2022} We do not create user accounts or profiles.
                        \u{2022} We do not sell, rent, or share data with third parties for marketing.
                        """)

                        sectionTitle("3. How We Use Information")
                        sectionBody("""
                        \u{2022} Math Problem Solving: Photos are sent to our AI provider via encrypted HTTPS to generate solutions. Images are processed in real-time and are not permanently stored on any external server.
                        \u{2022} Solution History: Solved problems (including a thumbnail of the original photo) are stored locally on your device so you can review past solutions.
                        \u{2022} Subscription Management: RevenueCat verifies your subscription status using an anonymous app user ID.
                        \u{2022} Personalization: Your education level adjusts the complexity of AI explanations.
                        """)
                    }

                    Group {
                        sectionTitle("4. Data Storage & Security")
                        sectionBody("""
                        \u{2022} Solution history is stored as a local JSON file in the app's sandboxed Documents directory.
                        \u{2022} User preferences are stored in iOS UserDefaults.
                        \u{2022} All on-device data is protected by iOS hardware encryption.
                        \u{2022} All network communication uses TLS 1.2+ encrypted HTTPS connections.
                        """)

                        sectionTitle("5. Third-Party Services")
                        sectionBody("""
                        \u{2022} AIProxy: Secure AI API gateway for math problem analysis.
                        \u{2022} OpenAI: AI model provider for generating solutions.
                        \u{2022} RevenueCat: Subscription and in-app purchase management.
                        \u{2022} Apple App Store: App distribution and payment processing.

                        Our AI service provider processes images solely for generating math solutions and does not retain image data after processing.
                        """)

                        sectionTitle("6. Children's Privacy")
                        sectionBody("MathPro is designed as an educational tool suitable for users of all ages, including children under 13. We do not collect personally identifiable information from any user. We do not require account creation, display targeted ads, or include social features.")

                        sectionTitle("7. Your Rights & Data Control")
                        highlightBox("""
                        \u{2022} View your data: Access solution history within the app at any time.
                        \u{2022} Delete individual solutions: Swipe to delete from history.
                        \u{2022} Delete all data: Settings > Clear All History.
                        \u{2022} Complete removal: Uninstalling MathPro permanently deletes all locally stored data.
                        \u{2022} Manage subscription: Apple ID > Subscriptions in device Settings.
                        """)

                        sectionTitle("8. Data Retention")
                        sectionBody("""
                        \u{2022} On-device data: Retained until you delete it or uninstall the app.
                        \u{2022} AI-processed images: Not retained by our AI provider after generating the response.
                        \u{2022} Subscription data: Managed by RevenueCat and Apple per their retention policies.
                        """)
                    }

                    Group {
                        sectionTitle("9. International Data Transfers")
                        sectionBody("When you use MathPro, image data is transmitted to AI service providers whose servers may be located in the United States or other countries. These transfers are protected by TLS encryption.")

                        sectionTitle("10. Changes to This Policy")
                        sectionBody("We may update this Privacy Policy from time to time. Material changes will be communicated by updating the Effective Date above. Continued use of MathPro after changes constitutes acceptance of the updated policy.")

                        sectionTitle("11. Contact Us")
                        sectionBody("""
                        Email: ahmetbugrakacdi@gmail.com
                        Developer: Ahmet Bugra Kacdi
                        App: MathPro - Math Problem Solver
                        """)
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
        Text(.init(text))
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func highlightBox(_ text: String) -> some View {
        Text(.init(text))
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.primary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(AppTheme.Colors.primary.opacity(0.2), lineWidth: 1)
                    )
            )
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

                    Text("Effective Date: March 26, 2026")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Group {
                        sectionBody("These Terms of Use govern your use of MathPro, an AI-powered math solving application developed by Ahmet Bugra Kacdi. By using MathPro, you agree to these Terms.")

                        sectionTitle("1. Acceptance of Terms")
                        sectionBody("By accessing or using MathPro, you confirm that you have read, understood, and agree to be bound by these Terms. If you do not agree, you must discontinue use immediately.")

                        sectionTitle("2. Description of Service")
                        sectionBody("MathPro is an educational application that analyzes photos of math problems using artificial intelligence and provides step-by-step solutions. The App is intended solely for educational and personal learning purposes.")

                        sectionTitle("3. Subscriptions & Payments")
                        sectionBody("""
                        \u{2022} Subscription Required: A Premium subscription is required to use the math solving feature.
                        \u{2022} Premium Plans: Weekly and Annual auto-renewable subscriptions are available.
                        \u{2022} Payment: All payments are processed by Apple through your Apple ID. We do not access your payment information.
                        \u{2022} Auto-Renewal: Subscriptions renew unless canceled at least 24 hours before the current period ends.
                        \u{2022} Cancellation: Manage or cancel via Settings > Apple ID > Subscriptions.
                        \u{2022} Refunds: Must be directed to Apple, as all payments are processed through the App Store.
                        """)
                    }

                    Group {
                        sectionTitle("4. Accuracy Disclaimer")
                        warningBox("MathPro uses AI to solve math problems. While we strive for accuracy, AI-generated solutions may occasionally contain errors. Always verify important results independently. MathPro should not be used as the sole source for exam answers, academic submissions, or critical calculations.")

                        sectionTitle("5. Acceptable Use")
                        sectionBody("""
                        You agree not to:
                        \u{2022} Use the App for academic dishonesty or cheating on exams
                        \u{2022} Reverse-engineer, decompile, or tamper with the App
                        \u{2022} Use the App for any unlawful purpose
                        \u{2022} Interfere with the App's servers or infrastructure
                        \u{2022} Circumvent usage limits or subscription requirements
                        \u{2022} Share or resell your subscription access
                        """)

                        sectionTitle("6. Intellectual Property")
                        sectionBody("All content, features, and code of MathPro are owned by the developer and protected by international copyright and intellectual property laws.")

                        sectionTitle("7. Limitation of Liability")
                        sectionBody("MathPro is provided \"as is\" without warranties of any kind. We do not warrant that the App will be error-free or that solutions will be 100% accurate. Our total liability shall not exceed the amount you paid for the App in the 12 months preceding any claim.")
                    }

                    Group {
                        sectionTitle("8. Governing Law")
                        sectionBody("These Terms shall be governed by the laws of the Republic of Turkey. Disputes shall be subject to the exclusive jurisdiction of the courts in Istanbul, Turkey.")

                        sectionTitle("9. Changes to Terms")
                        sectionBody("We may modify these Terms at any time. Continued use after changes constitutes acceptance of the revised Terms.")

                        sectionTitle("10. Contact")
                        sectionBody("""
                        Email: ahmetbugrakacdi@gmail.com
                        Developer: Ahmet Bugra Kacdi
                        App: MathPro - Math Problem Solver
                        """)
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
        Text(.init(text))
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func warningBox(_ text: String) -> some View {
        Text(.init(text))
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

#Preview("Privacy") { PrivacyPolicyView() }
#Preview("Terms") { TermsOfUseView() }
