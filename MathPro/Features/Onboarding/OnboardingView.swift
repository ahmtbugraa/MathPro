import SwiftUI
import RevenueCat

// MARK: - Main Onboarding Container
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0

    private let totalInfoSteps = 6

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
            // No skip button — user must go through all steps

            Spacer().frame(height: AppTheme.Spacing.xl)

            Group {
                switch currentStep {
                case 0: WelcomePage()
                case 1: CameraPage()
                case 2: EducationLevelPage()
                case 3: StepSolutionPage()
                case 4: ComparisonPage()
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
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var pulseGlow = false

    private let symbols = ["∫", "∑", "π", "√", "∞", "±", "x²", "sin", "cos", "log", "∂", "≠"]
    private let positions: [(CGFloat, CGFloat)] = [
        (60,80),(160,140),(280,60),(340,200),(80,300),(220,180),
        (300,350),(50,420),(180,480),(320,380),(120,250),(260,500)
    ]
    private let rotations: [Double] = [-15,10,-5,20,-12,8,-18,15,-8,22,-3,12]

    var body: some View {
        ZStack {
            // Floating math symbols background
            ForEach(0..<12, id: \.self) { i in
                Text(symbols[i])
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.primary.opacity(animate ? 0.15 : 0.0))
                    .position(x: positions[i].0, y: positions[i].1)
                    .rotationEffect(.degrees(animate ? rotations[i] + 10 : rotations[i]))
                    .scaleEffect(animate ? 1.1 : 0.7)
                    .animation(
                        .easeInOut(duration: 3.0 + Double(i) * 0.2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.15),
                        value: animate
                    )
            }

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // Icon with glow pulse
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.15))
                        .frame(width: 130, height: 130)
                        .scaleEffect(pulseGlow ? 1.2 : 0.9)
                        .opacity(pulseGlow ? 0.0 : 0.6)

                    Circle()
                        .fill(AppTheme.Colors.primarySoft)
                        .frame(width: 100, height: 100)

                    Image(systemName: "function")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                        .rotationEffect(.degrees(showIcon ? 0 : -90))
                }
                .scaleEffect(showIcon ? 1.0 : 0.3)
                .opacity(showIcon ? 1.0 : 0.0)

                VStack(spacing: AppTheme.Spacing.md) {
                    Text("welcome_title")
                        .font(AppTheme.Fonts.largeTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .offset(y: showTitle ? 0 : 30)
                        .opacity(showTitle ? 1 : 0)

                    Text("welcome_subtitle")
                        .font(AppTheme.Fonts.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .offset(y: showSubtitle ? 0 : 20)
                        .opacity(showSubtitle ? 1 : 0)
                }

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .onAppear {
            animate = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) { showIcon = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) { showTitle = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) { showSubtitle = true }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(1.0)) { pulseGlow = true }
        }
    }
}

// MARK: - Page 2: Camera
struct CameraPage: View {
    @State private var scanLineOffset: CGFloat = -36
    @State private var phase: Int = 0  // 0=scanning, 1=recognized, 2=solved
    @State private var showTitle = false
    @State private var showSubtitle = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()

            Text("Photograph & Solve Instantly")
                .font(AppTheme.Fonts.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .offset(y: showTitle ? 0 : 20)
                .opacity(showTitle ? 1 : 0)

            ZStack {
                // Phone frame
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 220, height: 240)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(AppTheme.Colors.divider, lineWidth: 1.5))

                ZStack {
                    // Math problem card
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

                    // Scan line — only visible during scanning phase
                    if phase == 0 {
                        Rectangle()
                            .fill(AppTheme.Colors.primary.opacity(0.65))
                            .frame(width: 170, height: 2)
                            .offset(y: scanLineOffset)
                    }

                    // Checkmark overlay when recognized
                    if phase >= 1 {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.primary, lineWidth: 2.5)
                            .frame(width: 170, height: 80)
                            .transition(.opacity)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(scanFrame.opacity(phase == 0 ? 1 : 0))
            }
            .frame(height: 240)

            // Result card — appears after scanning
            if phase >= 2 {
                VStack(spacing: AppTheme.Spacing.sm) {
                    // Answer badge
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.primary)
                            .font(.system(size: 18))
                        Text("x₁ = ½   x₂ = -3")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

                    // Mini steps
                    HStack(spacing: AppTheme.Spacing.sm) {
                        miniStep("1", "Δ = 49")
                        miniStep("2", "√49 = 7")
                        miniStep("3", "x = ½, -3")
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Subtitle text
            Text(subtitleText)
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .opacity(showSubtitle ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: phase)
                .contentTransition(.numericText())

            Spacer()
        }
        .onAppear { startAnimation() }
    }

    private var subtitleText: String {
        switch phase {
        case 0: return String(localized: "Point your camera at the problem — framing is automatic.")
        case 1: return String(localized: "Problem recognized!")
        default: return String(localized: "Solution ready in seconds.")
        }
    }

    private func miniStep(_ num: String, _ text: String) -> some View {
        VStack(spacing: 3) {
            ZStack {
                Circle().fill(AppTheme.Colors.primarySoft).frame(width: 22, height: 22)
                Text(num).font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.Colors.primary)
            }
            Text(text)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func startAnimation() {
        // Phase 0: scanning
        withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.3)) { showSubtitle = true }
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: true)) {
            scanLineOffset = 36
        }

        // Phase 1: recognized (after 2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.4)) { phase = 1 }
        }

        // Phase 2: solved (after 4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = 2 }
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

// MARK: - Page 3: Education Level Selection
struct EducationLevelPage: View {
    @AppStorage("educationLevel") private var selectedLevel: String = EducationLevel.high.rawValue

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            // Title
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .symbolRenderingMode(.hierarchical)

                Text("education_level_title")
                    .font(AppTheme.Fonts.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("education_level_subtitle")
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            // Level Cards
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(EducationLevel.allCases) { level in
                    let isSelected = selectedLevel == level.rawValue
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLevel = level.rawValue
                            EducationLevel.save(level)
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Text(level.emoji)
                                .font(.system(size: 28))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.localizedName)
                                    .font(AppTheme.Fonts.headline)
                                    .foregroundStyle(isSelected ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.divider, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                if isSelected {
                                    Circle()
                                        .fill(AppTheme.Colors.primary)
                                        .frame(width: 14, height: 14)
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(isSelected ? AppTheme.Colors.primarySoft : AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(isSelected ? AppTheme.Colors.primary.opacity(0.5) : AppTheme.Colors.divider, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            Spacer()
        }
    }
}

// MARK: - Page 4: Step Solution
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
    @State private var visibleItems = 0

    private let traditionalItems = [
        ("xmark", String(localized: "Manual solving")),
        ("xmark", String(localized: "Can't find errors")),
        ("xmark", String(localized: "Lost in textbooks")),
        ("xmark", String(localized: "Exam panic")),
    ]

    private let mathProItems = [
        ("checkmark", String(localized: "Instant solution")),
        ("checkmark", String(localized: "Step-by-step")),
        ("checkmark", String(localized: "Photo to solve")),
        ("checkmark", String(localized: "Truly learn")),
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Text("Why MathPro?")
                .font(AppTheme.Fonts.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                // Traditional card
                VStack(alignment: .leading, spacing: 0) {
                    Text("Traditional")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(.bottom, AppTheme.Spacing.sm)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<traditionalItems.count, id: \.self) { i in
                            if i < visibleItems {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppTheme.Colors.error)
                                    Text(traditionalItems[i].1)
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .transition(.opacity.combined(with: .offset(x: -10)))
                            }
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 190)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1.5))
                .opacity(highlight ? 0.5 : 1)

                // MathPro card
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.primary)
                        Text("MathPro AI")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                    .padding(.bottom, AppTheme.Spacing.sm)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<mathProItems.count, id: \.self) { i in
                            if i < visibleItems {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppTheme.Colors.primary)
                                    Text(mathProItems[i].1)
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .transition(.opacity.combined(with: .offset(x: -10)))
                            }
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 190)
                .background(AppTheme.Colors.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.primary.opacity(0.4), lineWidth: 1.5))
                .scaleEffect(highlight ? 1.03 : 1.0)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .animation(.spring(response: 0.4), value: visibleItems)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.3)) { highlight = true }
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.35) {
                    withAnimation { visibleItems = i }
                }
            }
        }
    }
}

// MARK: - Page 5: Social Proof
struct SocialProofPage: View {
    @State private var showNumber = false
    @State private var showStars = false
    @State private var visibleReviews = 0
    @State private var showTags = false

    private let reviews: [(String, String, String)] = [
        ("Elif K.", "review_1", "5"),
        ("Mert A.", "review_2", "5"),
        ("Zeynep D.", "review_3", "5"),
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            // Big number
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("10,000+")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .opacity(showNumber ? 1 : 0)
                    .scaleEffect(showNumber ? 1.0 : 0.5)

                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.yellow)
                            .opacity(showStars ? 1 : 0)
                            .scaleEffect(showStars ? 1.0 : 0.3)
                            .animation(.spring(response: 0.4).delay(0.6 + Double(i) * 0.1), value: showStars)
                    }
                }

                Text("students already use MathPro")
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .opacity(showNumber ? 1 : 0)
            }

            // Mini review cards
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<reviews.count, id: \.self) { i in
                    if i < visibleReviews {
                        HStack(spacing: AppTheme.Spacing.md) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.primarySoft)
                                    .frame(width: 36, height: 36)
                                Text(String(reviews[i].0.prefix(1)))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.primary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(reviews[i].0)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppTheme.Colors.textPrimary)
                                    Spacer()
                                    HStack(spacing: 1) {
                                        ForEach(0..<5, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                }
                                Text(LocalizedStringKey(reviews[i].1))
                                    .font(.system(size: 11))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .animation(.spring(response: 0.4), value: visibleReviews)

            // Subject tags
            VStack(spacing: AppTheme.Spacing.sm) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    subTag("Algebra", .purple); subTag("Geometry", .orange); subTag("Calculus", .indigo)
                }
                HStack(spacing: AppTheme.Spacing.sm) {
                    subTag("Trigonometry", .red); subTag("Statistics", .teal); subTag("Arithmetic", .blue)
                }
            }
            .opacity(showTags ? 1 : 0)
            .offset(y: showTags ? 0 : 15)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.2)) { showNumber = true }
            withAnimation(.spring(response: 0.4).delay(0.5)) { showStars = true }
            for i in 1...3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 + Double(i) * 0.4) {
                    withAnimation { visibleReviews = i }
                }
            }
            withAnimation(.easeOut(duration: 0.5).delay(2.2)) { showTags = true }
        }
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
    var subscriptionService = SubscriptionService.shared

    @State private var selectedPlan: PaywallView.PlanType = .weekly
    @State private var isProcessing = false
    @State private var showError = false
    @State private var showPrivacy = false
    @State private var showTerms = false

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

                    // Plans from RevenueCat
                    VStack(spacing: AppTheme.Spacing.sm) {
                        if let weekly = subscriptionService.weeklyPackage {
                            planRow(
                                type: .weekly,
                                title: weekly.hasFreeTrial
                                    ? (weekly.trialDurationText ?? String(localized: "Free Trial"))
                                    : String(localized: "Weekly"),
                                subtitle: weekly.hasFreeTrial
                                    ? String(localized: "then") + " " + weekly.localizedPrice + String(localized: "/ week")
                                    : weekly.localizedPrice + String(localized: "/ week"),
                                price: weekly.hasFreeTrial ? String(localized: "FREE") : weekly.localizedPrice,
                                badge: nil
                            )
                        }

                        if let annual = subscriptionService.annualPackage {
                            planRow(
                                type: .annual,
                                title: String(localized: "Annual Plan"),
                                subtitle: annual.localizedPrice + String(localized: "/ year"),
                                price: annual.localizedPrice,
                                badge: String(localized: "MOST POPULAR")
                            )
                        }

                        if subscriptionService.weeklyPackage == nil && subscriptionService.annualPackage == nil {
                            ProgressView()
                                .tint(AppTheme.Colors.primary)
                                .padding(AppTheme.Spacing.md)
                                .onAppear {
                                    Task { await subscriptionService.fetchOfferings() }
                                }
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
            }

            // CTA
            VStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    purchase()
                } label: {
                    if isProcessing { ProgressView().tint(.black) }
                    else {
                        let hasFreeTrial = subscriptionService.weeklyPackage?.hasFreeTrial == true && selectedPlan == .weekly
                        Text(hasFreeTrial ? String(localized: "Try for Free") : String(localized: "Subscribe Now"))
                    }
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
                    Button(String(localized: "Restore")) { restorePurchase() }
                        .font(.system(size: 11)).foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("•").foregroundStyle(AppTheme.Colors.textTertiary).font(.system(size: 11))
                    Button(String(localized: "Privacy")) { showPrivacy = true }
                        .font(.system(size: 11)).foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("•").foregroundStyle(AppTheme.Colors.textTertiary).font(.system(size: 11))
                    Button(String(localized: "Terms")) { showTerms = true }
                        .font(.system(size: 11)).foregroundStyle(AppTheme.Colors.textTertiary)
                }

                // Skip option
                Button {
                    onComplete()
                } label: {
                    Text(String(localized: "Continue with free plan"))
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .underline()
                }
                .padding(.top, AppTheme.Spacing.xs)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
            .background(AppTheme.Colors.background)
        }
        .alert(String(localized: "Error"), isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(subscriptionService.errorMessage ?? String(localized: "An error occurred"))
        }
        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
        .sheet(isPresented: $showTerms) { TermsOfUseView() }
    }

    private func featureRow(_ emoji: String, _ text: LocalizedStringKey) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(emoji).font(.title3)
            Text(text).font(AppTheme.Fonts.callout).foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }

    private func planRow(type: PaywallView.PlanType, title: String, subtitle: String, price: String, badge: String?) -> some View {
        let isSelected = selectedPlan == type
        return Button { withAnimation(.spring(response: 0.25)) { selectedPlan = type } } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle().stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.divider, lineWidth: 2).frame(width: 22, height: 22)
                    if isSelected { Circle().fill(AppTheme.Colors.primary).frame(width: 12, height: 12) }
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(title)
                            .font(AppTheme.Fonts.headline).foregroundStyle(AppTheme.Colors.textPrimary)
                        if let badge {
                            Text(badge).font(.system(size: 9, weight: .black)).foregroundStyle(.black)
                                .padding(.horizontal, 7).padding(.vertical, 3)
                                .background(AppTheme.Colors.primary).clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(AppTheme.Fonts.caption).foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
                Text(price)
                    .font(AppTheme.Fonts.headline)
                    .foregroundStyle(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
            }
            .padding(AppTheme.Spacing.md)
            .background(isSelected ? AppTheme.Colors.primarySoft : AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 1.5))
        }
    }

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
                if success { onComplete() }
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
                if restored { onComplete() }
                else if subscriptionService.errorMessage != nil { showError = true }
            }
        }
    }
}

#Preview { OnboardingView() }
