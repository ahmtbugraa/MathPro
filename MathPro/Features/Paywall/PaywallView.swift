import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    /// Optional callback for onboarding flow — when set, shows "Maybe later" instead of X close button
    var onComplete: (() -> Void)? = nil

    @ObservedObject private var subscriptionService = SubscriptionService.shared

    @State private var selectedPlan: PlanType = .annual
    @State private var isProcessing = false
    @State private var showError = false
    @State private var showRestoreSuccess = false
    @State private var showPrivacy = false
    @State private var showTerms = false

    // Animations
    @State private var headerAppeared = false
    @State private var featuresAppeared = false
    @State private var plansAppeared = false
    @State private var scanLineOffset: CGFloat = -1.0
    @State private var scanPulse = false

    enum PlanType {
        case weekly, annual
    }

    var body: some View {
        ZStack {
            // Background gradient
            backgroundView

            VStack(spacing: 0) {
                // Close button
                closeButton

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        featuresSection
                            .padding(.top, 20)
                        planSection
                            .padding(.top, 20)
                        ctaSection
                            .padding(.top, 18)
                        legalSection
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { animateIn() }
        .alert(String(localized: "Error"), isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(subscriptionService.errorMessage ?? String(localized: "An error occurred"))
        }
        .alert(String(localized: "Restored!"), isPresented: $showRestoreSuccess) {
            Button("OK") {
                if let onComplete { onComplete() } else { dismiss() }
            }
        } message: {
            Text(String(localized: "Your subscription has been restored."))
        }
        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
        .sheet(isPresented: $showTerms) { TermsOfUseView() }
    }

    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            // Subtle green glow at top
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.Colors.primary.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(y: -120)
                    .blur(radius: 60)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Close Button
    private var closeButton: some View {
        HStack {
            Spacer()
            // Hide close X when in onboarding mode (onComplete is set)
            if onComplete == nil {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Close")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Scanning animation — wide & compact
            scanAnimationView
                .opacity(headerAppeared ? 1 : 0)
                .scaleEffect(headerAppeared ? 1 : 0.85)

            VStack(spacing: 6) {
                Text(String(localized: "Unlock MathPro"))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(String(localized: "Solve any math problem instantly with AI"))
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(headerAppeared ? 1 : 0)
            .offset(y: headerAppeared ? 0 : 10)
        }
    }

    // MARK: - Scan Animation
    private var scanAnimationView: some View {
        let boxH: CGFloat = 56

        return ZStack {
            // Glow background
            RoundedRectangle(cornerRadius: 10)
                .fill(AppTheme.Colors.primary.opacity(scanPulse ? 0.06 : 0.02))
                .padding(.horizontal, 12)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: scanPulse)

            // Math equation — single line, centered
            HStack(spacing: 16) {
                Text("2x\u{00B2} + 5x - 3 = 0")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.65))
                Text("\u{2192}")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.primary.opacity(0.6))
                Text("x = ?")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.primary.opacity(0.8))
            }

            // Scan line
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.primary.opacity(0),
                            AppTheme.Colors.primary.opacity(0.7),
                            AppTheme.Colors.primary.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, 26)
                .offset(y: scanLineOffset * (boxH / 2 - 6))

            // Corner brackets — drawn via Canvas for precise positioning
            Canvas { context, size in
                let inset: CGFloat = 20
                let bLen: CGFloat = 14
                let rect = CGRect(x: inset, y: 0, width: size.width - inset * 2, height: size.height)
                let color = Color(red: 0.13, green: 0.77, blue: 0.37)

                // Helper to draw an L-bracket
                func drawBracket(_ p1: CGPoint, _ corner: CGPoint, _ p2: CGPoint) {
                    var path = Path()
                    path.move(to: p1)
                    path.addLine(to: corner)
                    path.addLine(to: p2)
                    context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                }

                // Top-left
                drawBracket(
                    CGPoint(x: rect.minX, y: rect.minY + bLen),
                    CGPoint(x: rect.minX, y: rect.minY),
                    CGPoint(x: rect.minX + bLen, y: rect.minY)
                )
                // Top-right
                drawBracket(
                    CGPoint(x: rect.maxX - bLen, y: rect.minY),
                    CGPoint(x: rect.maxX, y: rect.minY),
                    CGPoint(x: rect.maxX, y: rect.minY + bLen)
                )
                // Bottom-left
                drawBracket(
                    CGPoint(x: rect.minX, y: rect.maxY - bLen),
                    CGPoint(x: rect.minX, y: rect.maxY),
                    CGPoint(x: rect.minX + bLen, y: rect.maxY)
                )
                // Bottom-right
                drawBracket(
                    CGPoint(x: rect.maxX - bLen, y: rect.maxY),
                    CGPoint(x: rect.maxX, y: rect.maxY),
                    CGPoint(x: rect.maxX, y: rect.maxY - bLen)
                )
            }
        }
        .frame(height: boxH)
        .padding(.horizontal, 20)
        .onAppear {
            scanPulse = true
            withAnimation(
                .easeInOut(duration: 1.6)
                .repeatForever(autoreverses: true)
            ) {
                scanLineOffset = 1.0
            }
        }
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureItem(
                icon: "camera.viewfinder",
                title: String(localized: "Snap & Solve"),
                subtitle: String(localized: "Take a photo, get instant answers"),
                isFirst: true
            )
            featureItem(
                icon: "text.line.first.and.arrowtriangle.forward",
                title: String(localized: "Step-by-Step"),
                subtitle: String(localized: "Detailed explanations for every step"),
                isFirst: false
            )
            featureItem(
                icon: "infinity",
                title: String(localized: "Unlimited Solves"),
                subtitle: String(localized: "No daily limits, solve all you want"),
                isFirst: false
            )
            featureItem(
                icon: "globe",
                title: String(localized: "Multi-Language"),
                subtitle: String(localized: "Solutions in your language"),
                isFirst: false
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .opacity(featuresAppeared ? 1 : 0)
        .offset(y: featuresAppeared ? 0 : 15)
    }

    private func featureItem(icon: String, title: String, subtitle: String, isFirst: Bool) -> some View {
        VStack(spacing: 0) {
            if !isFirst {
                Rectangle()
                    .fill(Color.white.opacity(0.04))
                    .frame(height: 1)
                    .padding(.vertical, 8)
            }

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.Colors.primary.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }

                Spacer()
            }
        }
    }

    // MARK: - Plans
    private var planSection: some View {
        VStack(spacing: 10) {
            // Annual — recommended
            annualPlanCard
            // Weekly
            weeklyPlanCard
        }
        .opacity(plansAppeared ? 1 : 0)
        .offset(y: plansAppeared ? 0 : 15)
    }

    @ViewBuilder
    private var annualPlanCard: some View {
        if let pkg = subscriptionService.annualPackage {
            let isSelected = selectedPlan == .annual
            let priceText = pkg.localizedPrice + String(localized: "/ year")

            Button {
                withAnimation(.spring(response: 0.3)) { selectedPlan = .annual }
            } label: {
                VStack(spacing: 0) {
                    // "Best Value" banner
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text(String(localized: "BEST VALUE"))
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.primary)

                    // Content
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Annual Plan"))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(priceText)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }

                        Spacer()

                        // Radio
                        radioCircle(selected: isSelected)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? AppTheme.Colors.primary.opacity(0.08) : Color.white.opacity(0.03))
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isSelected ? AppTheme.Colors.primary : Color.white.opacity(0.08),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .accessibilityLabel("Annual Plan, \(pkg.localizedPrice) per year")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }

    @ViewBuilder
    private var weeklyPlanCard: some View {
        if let pkg = subscriptionService.weeklyPackage {
            let isSelected = selectedPlan == .weekly
            let hasFreeTrial = pkg.hasFreeTrial
            let titleText: String = hasFreeTrial
                ? (pkg.trialDurationText ?? String(localized: "Free Trial"))
                : String(localized: "Weekly")
            let subtitleText: String = hasFreeTrial
                ? String(localized: "then") + " " + pkg.localizedPrice + String(localized: "/ week")
                : pkg.localizedPrice + String(localized: "/ week")

            Button {
                withAnimation(.spring(response: 0.3)) { selectedPlan = .weekly }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(titleText)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(subtitleText)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    radioCircle(selected: isSelected)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? AppTheme.Colors.primary.opacity(0.08) : Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isSelected ? AppTheme.Colors.primary : Color.white.opacity(0.08),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .accessibilityLabel("\(titleText), \(subtitleText)")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }

        // Fallback loading
        if subscriptionService.weeklyPackage == nil && subscriptionService.annualPackage == nil {
            ProgressView()
                .tint(AppTheme.Colors.primary)
                .padding(AppTheme.Spacing.lg)
                .onAppear {
                    Task { await subscriptionService.fetchOfferings() }
                }
        }
    }

    private func radioCircle(selected: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(selected ? AppTheme.Colors.primary : Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 24, height: 24)
            if selected {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 14, height: 14)
            }
        }
    }

    // MARK: - CTA
    private var ctaSection: some View {
        ctaSectionContent
    }

    @ViewBuilder
    private var ctaSectionContent: some View {
        let pkg = selectedPlan == .weekly
            ? subscriptionService.weeklyPackage
            : subscriptionService.annualPackage
        let hasFreeTrial = pkg?.hasFreeTrial == true && selectedPlan == .weekly

        VStack(spacing: 12) {
            // Subscribe button
            Button {
                purchase()
            } label: {
                HStack(spacing: 8) {
                    if isProcessing {
                        ProgressView().tint(.black)
                    } else {
                        let btnText: String = hasFreeTrial
                            ? String(localized: "Start Free Trial")
                            : String(localized: "Subscribe Now")
                        Text(btnText)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.primary, Color(red: 0.16, green: 0.85, blue: 0.45)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 12, y: 4)
            }
            .disabled(isProcessing)
            .scaleEffect(isProcessing ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isProcessing)
            .accessibilityLabel("Subscribe")

            // Trial detail
            if let pkg, hasFreeTrial, let trialText = pkg.trialDurationText {
                let detail = trialText + ". " + String(localized: "Then") + " " + pkg.localizedPrice + pkg.localizedPeriod + "."
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            // Apple-required disclosure
            Text(String(localized: "apple_subscription_disclosure"))
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
    }

    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: 10) {
            // Restore
            Button {
                restorePurchase()
            } label: {
                Text(String(localized: "Restore Purchase"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .accessibilityLabel("Restore purchases")

            // Privacy & Terms
            HStack(spacing: 16) {
                Button(String(localized: "Privacy Policy")) { showPrivacy = true }
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                Button(String(localized: "Terms of Use")) { showTerms = true }
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            // "Maybe later" — only in onboarding mode
            if let onComplete {
                Button {
                    onComplete()
                } label: {
                    Text(String(localized: "Maybe later"))
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .underline()
                }
                .padding(.top, 4)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Animations
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            headerAppeared = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25)) {
            featuresAppeared = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
            plansAppeared = true
        }
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
                if success {
                    if let onComplete { onComplete() } else { dismiss() }
                } else if subscriptionService.errorMessage != nil { showError = true }
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
