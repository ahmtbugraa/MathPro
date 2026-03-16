import SwiftUI

// MARK: - Main Onboarding Container
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0

    private let totalInfoSteps = 5

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            if currentStep < totalInfoSteps {
                infoPageView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .id(currentStep)
            } else {
                OnboardingPaywallView {
                    hasSeenOnboarding = true
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentStep)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var infoPageView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { hasSeenOnboarding = true }
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(AppTheme.Spacing.md)
            }

            Group {
                switch currentStep {
                case 0: WelcomePage()
                case 1: CameraPage()
                case 2: StepSolutionPage()
                case 3: ComparisonPage()
                default: SocialProofPage()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: AppTheme.Spacing.md) {
                dotsView
                Button { withAnimation { currentStep += 1 } } label: { Text("Continue") }
                    .primaryButton()
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private var dotsView: some View {
        HStack(spacing: 6) {
            ForEach(0..<(totalInfoSteps + 1), id: \.self) { i in
                Capsule()
                    .fill(i == currentStep ? AppTheme.Colors.primary : AppTheme.Colors.divider)
                    .frame(width: i == currentStep ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
}

// MARK: - Page 1: Welcome
struct WelcomePage: View {
    @State private var animate = false
    private let symbols = ["∫", "∑", "π", "√", "∞", "±", "x²", "sin", "cos", "log", "∂", "≠"]
    private let positions: [(CGFloat, CGFloat)] = [
        (60,80),(160,140),(280,60),(340,200),(80,300),(220,180),
        (300,350),(50,420),(180,480),(320,380),(120,250),(260,500)
    ]
    private let rotations: [Double] = [-15,10,-5,20,-12,8,-18,15,-8,22,-3,12]

    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Text(symbols[i])
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.primary.opacity(0.10))
                    .position(x: positions[i].0, y: positions[i].1)
                    .rotationEffect(.degrees(rotations[i]))
                    .scaleEffect(animate ? 1.07 : 0.95)
                    .animation(.easeInOut(duration: 3.0 + Double(i) * 0.15).repeatForever(autoreverses: true).delay(Double(i) * 0.18), value: animate)
            }

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()
                ZStack {
                    Circle().fill(AppTheme.Colors.primarySoft).frame(width: 100, height: 100)
                    Image(systemName: "function")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("welcome_title")
                        .font(AppTheme.Fonts.largeTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("welcome_subtitle")
                        .font(AppTheme.Fonts.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Page 2: Camera
struct CameraPage: View {
    @State private var scanLineOffset: CGFloat = -36

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Text("Photograph & Solve Instantly")
                .font(AppTheme.Fonts.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 220, height: 280)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(AppTheme.Colors.divider, lineWidth: 1.5))

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.94))
                        .frame(width: 170, height: 80)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("2x² + 5x - 3 = 0")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(.black)
                        Text("x = ?")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.gray)
                    }
                    Rectangle()
                        .fill(AppTheme.Colors.primary.opacity(0.65))
                        .frame(width: 170, height: 2)
                        .offset(y: scanLineOffset)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(scanFrame)
            }
            .frame(height: 280)

            Text("Point your camera at the problem — framing is automatic.")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: true)) {
                scanLineOffset = 36
            }
        }
    }

    private var scanFrame: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height, s: CGFloat = 12, t: CGFloat = 2
            ZStack {
                Path { p in p.move(to: .init(x: 0, y: s)); p.addLine(to: .init(x: 0, y: 0)); p.addLine(to: .init(x: s, y: 0)) }.stroke(AppTheme.Colors.primary, lineWidth: t)
                Path { p in p.move(to: .init(x: w-s, y: 0)); p.addLine(to: .init(x: w, y: 0)); p.addLine(to: .init(x: w, y: s)) }.stroke(AppTheme.Colors.primary, lineWidth: t)
                Path { p in p.move(to: .init(x: 0, y: h-s)); p.addLine(to: .init(x: 0, y: h)); p.addLine(to: .init(x: s, y: h)) }.stroke(AppTheme.Colors.primary, lineWidth: t)
                Path { p in p.move(to: .init(x: w-s, y: h)); p.addLine(to: .init(x: w, y: h)); p.addLine(to: .init(x: w, y: h-s)) }.stroke(AppTheme.Colors.primary, lineWidth: t)
            }
        }
    }
}

// MARK: - Page 3: Step Solution
struct StepSolutionPage: View {
    @State private var visibleSteps = 0
    private let steps = [
        ("1", "Find the discriminant", "Δ = 25 + 24 = 49"),
        ("2", "Take the square root", "√49 = 7"),
        ("3", "Results", "x = ½  or  x = -3"),
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Text("Learn Step by Step")
                .font(AppTheme.Fonts.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack {
                Image(systemName: "checkmark.seal.fill").foregroundStyle(AppTheme.Colors.primary)
                Text("x₁ = ½   •   x₂ = -3")
                    .font(AppTheme.Fonts.headline)
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.primarySoft)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .padding(.horizontal, AppTheme.Spacing.xl)

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<steps.count, id: \.self) { i in
                    if i < visibleSteps {
                        HStack(spacing: AppTheme.Spacing.md) {
                            ZStack {
                                Circle().fill(AppTheme.Colors.primarySoft).frame(width: 28, height: 28)
                                Text(steps[i].0).font(AppTheme.Fonts.caption).fontWeight(.bold).foregroundStyle(AppTheme.Colors.primary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(steps[i].1).font(AppTheme.Fonts.callout).fontWeight(.semibold).foregroundStyle(AppTheme.Colors.textPrimary)
                                Text(steps[i].2).font(.system(size: 13, design: .monospaced)).foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(AppTheme.Spacing.sm)
                        .cardStyle()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .animation(.spring(response: 0.4), value: visibleSteps)

            Text("Each step is explained with the reason it was performed.")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()
        }
        .onAppear {
            for i in 1...3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.45) { visibleSteps = i }
            }
        }
    }
}

// MARK: - Page 4: Comparison
struct ComparisonPage: View {
    @State private var highlight = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Text("Why MathPro?")
                .font(AppTheme.Fonts.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                compCard(title: "Traditional", highlighted: false, items: [
                    ("xmark", "Hours of manual work"),
                    ("xmark", "Don't know where the error is"),
                    ("xmark", "Getting lost in textbooks"),
                    ("xmark", "Panicking during exam stress"),
                ])
                .opacity(highlight ? 0.5 : 1)

                compCard(title: "MathPro AI", highlighted: true, items: [
                    ("checkmark", "Solution in seconds"),
                    ("checkmark", "Every step explained"),
                    ("checkmark", "Start with a photo"),
                    ("checkmark", "Truly learn"),
                ])
                .scaleEffect(highlight ? 1.04 : 1.0)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.3)) { highlight = true }
        }
    }

    private func compCard(title: String, highlighted: Bool, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                if highlighted { Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.Colors.primary) }
                Text(title)
                    .font(AppTheme.Fonts.callout).fontWeight(.bold)
                    .foregroundStyle(highlighted ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            }
            .padding(.bottom, 2)
            ForEach(items, id: \.1) { icon, text in
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(highlighted ? AppTheme.Colors.primary : AppTheme.Colors.error)
                        .padding(.top, 2)
                    Text(text).font(.system(size: 12)).foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(highlighted ? AppTheme.Colors.primarySoft : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md)
            .stroke(highlighted ? AppTheme.Colors.primary.opacity(0.4) : AppTheme.Colors.divider, lineWidth: 1.5))
    }
}

// MARK: - Page 5: Social Proof
struct SocialProofPage: View {
    @State private var show = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("10,000+")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? 0 : 20)
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { _ in Image(systemName: "star.fill").font(.caption).foregroundStyle(.yellow) }
                }
                Text("students already use MathPro")
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    subTag("Algebra", .purple); subTag("Geometry", .orange); subTag("Calculus", .indigo)
                }
                HStack(spacing: AppTheme.Spacing.sm) {
                    subTag("Trigonometry", .red); subTag("Statistics", .teal); subTag("Arithmetic", .blue)
                }
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "cpu").foregroundStyle(AppTheme.Colors.textTertiary)
                Text("Powered by Claude AI")
                    .font(AppTheme.Fonts.caption).foregroundStyle(AppTheme.Colors.textTertiary)
            }
            .padding(.horizontal, AppTheme.Spacing.md).padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.surface).clipShape(Capsule())

            Spacer()
        }
        .onAppear { withAnimation(.spring(response: 0.5).delay(0.2)) { show = true } }
    }

    private func subTag(_ label: LocalizedStringKey, _ color: Color) -> some View {
        Text(label).font(.system(size: 13, weight: .medium)).foregroundStyle(color)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(color.opacity(0.12)).clipShape(Capsule())
    }
}

// MARK: - Onboarding Paywall (Last step)
struct OnboardingPaywallView: View {
    let onComplete: () -> Void
    @State private var selectedPlan: Bool = true  // true = trial, false = annual
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Rating
                    VStack(spacing: 6) {
                        HStack(spacing: 3) {
                            ForEach(0..<5, id: \.self) { _ in Image(systemName: "star.fill").font(.callout).foregroundStyle(.yellow) }
                        }
                        Text("4.8 / App Store").font(AppTheme.Fonts.caption).foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

                    Text("Get Unlimited Access")
                        .font(AppTheme.Fonts.largeTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        featureRow("🔥", "Unlimited math solutions")
                        featureRow("📋", "AI-powered step-by-step explanation")
                        featureRow("🤖", "Ask AI, learn by understanding")
                        featureRow("📚", "All history saved")
                    }
                    .padding(AppTheme.Spacing.md)
                    .cardStyle()

                    // Plans
                    VStack(spacing: AppTheme.Spacing.sm) {
                        planRow(isTrial: true)
                        planRow(isTrial: false)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
            }

            // CTA
            VStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    isProcessing = true
                    Task {
                        try? await Task.sleep(for: .seconds(1.0))
                        await MainActor.run { isProcessing = false; onComplete() }
                    }
                } label: {
                    if isProcessing { ProgressView().tint(.black) }
                    else { Text("Try for Free") }
                }
                .primaryButton()
                .disabled(isProcessing)
                .padding(.horizontal, AppTheme.Spacing.xl)

                HStack(spacing: 5) {
                    Image(systemName: "checkmark.shield.fill").font(.caption).foregroundStyle(AppTheme.Colors.primary)
                    Text("No payment now. Cancel anytime.")
                        .font(AppTheme.Fonts.caption).foregroundStyle(AppTheme.Colors.textSecondary)
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    Button("Restore") {}.font(.system(size: 11)).foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("•").foregroundStyle(AppTheme.Colors.textTertiary).font(.system(size: 11))
                    Button("Privacy") {}.font(.system(size: 11)).foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("•").foregroundStyle(AppTheme.Colors.textTertiary).font(.system(size: 11))
                    Button("Terms") {}.font(.system(size: 11)).foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
            .background(AppTheme.Colors.background)
        }
    }

    private func featureRow(_ emoji: String, _ text: LocalizedStringKey) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(emoji).font(.title3)
            Text(text).font(AppTheme.Fonts.callout).foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }

    private func planRow(isTrial: Bool) -> some View {
        let isSelected = selectedPlan == isTrial
        return Button { withAnimation(.spring(response: 0.25)) { selectedPlan = isTrial } } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle().stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.divider, lineWidth: 2).frame(width: 22, height: 22)
                    if isSelected { Circle().fill(AppTheme.Colors.primary).frame(width: 12, height: 12) }
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(isTrial ? "3 Days Free" : "Annual Plan")
                            .font(AppTheme.Fonts.headline).foregroundStyle(AppTheme.Colors.textPrimary)
                        if !isTrial {
                            Text("MOST POPULAR").font(.system(size: 9, weight: .black)).foregroundStyle(.black)
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(AppTheme.Colors.primary).clipShape(Capsule())
                        }
                    }
                    Text(isTrial ? "then ₺149.00/week" : "₺549.00/year • ₺10.53/week")
                        .font(AppTheme.Fonts.caption).foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
                Text(isTrial ? "FREE" : "₺549")
                    .font(isTrial ? AppTheme.Fonts.headline : AppTheme.Fonts.callout)
                    .foregroundStyle(isTrial ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
            }
            .padding(AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.primarySoft : AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 1.5))
        }
    }
}

#Preview { OnboardingView() }
