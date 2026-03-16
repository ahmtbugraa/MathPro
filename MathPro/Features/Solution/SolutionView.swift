import SwiftUI
import SwiftData
import StoreKit

struct SolutionView: View {
    let image: UIImage

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var solution: MathSolution?
    @State private var isLoading  = true
    @State private var errorMessage: String?
    @State private var isSaved    = false
    @State private var showPaywall = false
    @State private var showLimitAlert = false

    private let aiService   = AIService()
    private let usage       = UsageService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                if isLoading {
                    SolvingLoadingView(image: image)
                } else if let error = errorMessage {
                    errorView(error)
                } else if let sol = solution {
                    solutionContent(sol)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if solution != nil {
                        Button { saveToHistory() } label: {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(isSaved ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .task { await checkLimitAndSolve() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("Go Premium") { showPaywall = true }
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(String(format: NSLocalizedString("daily_limit_message", comment: ""), Config.freeDailySolveLimit))
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Error
    private func errorView(_ msg: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(AppTheme.Colors.error)
            Text("An error occurred")
                .font(AppTheme.Fonts.title2)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(msg)
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            Button("Try Again") { Task { await checkLimitAndSolve() } }
                .primaryButton()
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    // MARK: - Solution Content
    private func solutionContent(_ sol: MathSolution) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {

                // Captured image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    .frame(maxWidth: .infinity)

                // Subject + problem
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    HStack {
                        Label(sol.subject.rawValue, systemImage: sol.subject.icon)
                            .font(AppTheme.Fonts.caption)
                            .foregroundStyle(sol.subject.color)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(sol.subject.color.opacity(0.15))
                            .clipShape(Capsule())
                        Spacer()
                        if !usage.isPremium {
                            (Text(verbatim: "\(usage.remaining) ") + Text("solves remaining"))
                                .font(AppTheme.Fonts.caption)
                                .foregroundStyle(usage.remaining <= 1 ? AppTheme.Colors.error : AppTheme.Colors.textTertiary)
                        }
                    }
                    Text(sol.problem)
                        .font(AppTheme.Fonts.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
                .cardStyle()

                // Answer — KaTeX render
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("ANSWER")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    if sol.answer.contains("\\") || sol.answer.contains("^") || sol.answer.contains("_") {
                        DisplayMathView(latex: sol.answer)
                    } else {
                        Text(sol.answer)
                            .font(AppTheme.Fonts.title)
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                        .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                )

                // Steps
                if !sol.steps.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("STEP-BY-STEP SOLUTION")
                            .font(AppTheme.Fonts.caption)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                            .padding(.bottom, AppTheme.Spacing.xs)

                        ForEach(Array(sol.steps.enumerated()), id: \.element.id) { idx, step in
                            StepCardView(step: step)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.spring(response: 0.4).delay(Double(idx) * 0.08), value: sol.id)
                        }
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Actions
    private func checkLimitAndSolve() async {
        guard usage.canSolve else {
            isLoading = false
            showLimitAlert = true
            return
        }
        await solve()
    }

    private func solve() async {
        isLoading = true
        errorMessage = nil
        do {
            solution = try await aiService.solve(image: image)
            usage.recordSolve()
            autoSave()
            if usage.shouldShowReview {
                try? await Task.sleep(for: .seconds(1.5))
                await requestReview()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func autoSave() {
        guard let sol = solution else { return }
        let record = SolveRecord(from: sol, imageData: image.jpegData(compressionQuality: 0.5))
        modelContext.insert(record)
        isSaved = true
    }

    private func saveToHistory() {
        guard let sol = solution, !isSaved else { return }
        let record = SolveRecord(from: sol, imageData: image.jpegData(compressionQuality: 0.5))
        modelContext.insert(record)
        isSaved = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Animated Loading View
struct SolvingLoadingView: View {
    let image: UIImage

    @State private var rotation: Double = 0
    @State private var currentStep = 0
    @State private var progress: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var elapsedSeconds = 0

    private let steps: [(icon: String, text: LocalizedStringKey)] = [
        ("camera.viewfinder",   "Analyzing image..."),
        ("text.viewfinder",     "Reading math problem..."),
        ("brain.head.profile",  "Thinking step by step..."),
        ("function",            "Calculating solution..."),
        ("checkmark.circle",    "Preparing explanation...")
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Thumbnail of captured image
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 120)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: AppTheme.Colors.primary.opacity(0.2), radius: 12)
                .scaleEffect(pulseScale)

            // Animated spinner
            ZStack {
                // Background ring
                Circle()
                    .stroke(AppTheme.Colors.primarySoft, lineWidth: 5)
                    .frame(width: 72, height: 72)

                // Spinning arc
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(AppTheme.Colors.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(rotation))

                // Center icon (changes per step)
                Image(systemName: steps[currentStep].icon)
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .contentTransition(.symbolEffect(.replace))
            }

            // Step text
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(steps[currentStep].text)
                    .font(AppTheme.Fonts.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.Colors.surface)
                        .frame(width: 200, height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 200 * progress, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }

                // Elapsed time
                Text(verbatim: "\(elapsedSeconds)s")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            // Step indicators
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i <= currentStep ? AppTheme.Colors.primary : AppTheme.Colors.divider)
                        .frame(width: 8, height: 8)
                        .scaleEffect(i == currentStep ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
        }
        .padding(AppTheme.Spacing.xl)
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Continuous spinner rotation
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // Gentle pulse on image
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 0.96
        }

        // Step progression timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                elapsedSeconds += 1

                // Progress bar grows over time
                let maxTime: CGFloat = 30
                progress = min(CGFloat(elapsedSeconds) / maxTime, 0.95)

                // Advance step every ~4 seconds
                let newStep = min(elapsedSeconds / 4, steps.count - 1)
                if newStep != currentStep {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = newStep
                    }
                }

                // Stop timer if view disappears (safety)
                if elapsedSeconds > 120 { timer.invalidate() }
            }
        }
    }
}
