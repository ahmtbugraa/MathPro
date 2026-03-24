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
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?

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
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if solution != nil {
                        HStack(spacing: 12) {
                            // Share button
                            Button { shareSolution() } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            // Bookmark
                            Button { saveToHistory() } label: {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .foregroundStyle(isSaved ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { startSolving() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ShareSheetView(image: shareImage)
            }
        }
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
            Button("Try Again") { solveTask = nil; startSolving() }
                .primaryButton()
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    // MARK: - Solution Content (Notebook Style)
    private func solutionContent(_ sol: MathSolution) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Header: Image + Subject ──
                headerSection(sol)

                // ── Answer Card ──
                answerCard(sol)
                    .padding(.top, 20)

                // ── Action Buttons ──
                actionButtons(sol)
                    .padding(.top, 16)

                // ── Notebook Divider ──
                notebookDivider
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                // ── Steps Section Label ──
                HStack(spacing: 8) {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                    Text("STEP-BY-STEP SOLUTION")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .tracking(1.2)
                }
                .padding(.bottom, 16)

                // ── Timeline Steps ──
                if !sol.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(sol.steps.enumerated()), id: \.element.id) { idx, step in
                            StepCardView(
                                step: step,
                                isLast: idx == sol.steps.count - 1
                            )
                        }
                    }
                }

                // ── Final Answer Badge ──
                finalAnswerBadge(sol)
                    .padding(.top, 20)

                // ── Confidence indicator ──
                if sol.confidence > 0 {
                    confidenceBar(sol.confidence)
                        .padding(.top, 16)
                }

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Header Section
    private func headerSection(_ sol: MathSolution) -> some View {
        HStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                Label(sol.subject.rawValue, systemImage: sol.subject.icon)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(sol.subject.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(sol.subject.color.opacity(0.12))
                    .clipShape(Capsule())

                Text(sol.problem)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            if !usage.isPremium {
                VStack(spacing: 2) {
                    Text(verbatim: "\(usage.remaining)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(usage.remaining <= 1 ? AppTheme.Colors.error : AppTheme.Colors.primary)
                    Text("left")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .frame(width: 44)
            }
        }
    }

    // MARK: - Answer Card
    private func answerCard(_ sol: MathSolution) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.Colors.primary)
                Text("ANSWER")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .tracking(1.5)
                Spacer()
            }

            if sol.answer.contains("\\") || sol.answer.contains("^") || sol.answer.contains("_") {
                DisplayMathView(latex: sol.answer, fontSize: 24)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text(sol.answer)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.Colors.primary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [AppTheme.Colors.primary.opacity(0.5), AppTheme.Colors.primary.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }

    // MARK: - Action Buttons
    private func actionButtons(_ sol: MathSolution) -> some View {
        HStack(spacing: 12) {
            // Share
            Button {
                shareSolution()
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.12))
                            .frame(height: 44)
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.blue)
                    }
                    Text("share_solution")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: - Notebook Divider
    private var notebookDivider: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.25))
                    .frame(width: 4, height: 4)
            }
            Rectangle()
                .fill(AppTheme.Colors.divider.opacity(0.5))
                .frame(height: 1)
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.25))
                    .frame(width: 4, height: 4)
            }
        }
    }

    // MARK: - Final Answer Badge
    private func finalAnswerBadge(_ sol: MathSolution) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Solution Complete")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary)
                Text("\(sol.steps.count) \(String(localized: "steps"))")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.Colors.primary.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.Colors.primary.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - Confidence Bar
    private func confidenceBar(_ confidence: Double) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.Colors.textTertiary)

            Text("Confidence")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textTertiary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.Colors.surface)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(confidenceColor(confidence))
                        .frame(width: geo.size.width * confidence, height: 6)
                }
            }
            .frame(height: 6)

            Text(verbatim: "\(Int(confidence * 100))%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(confidenceColor(confidence))
        }
    }

    private func confidenceColor(_ c: Double) -> Color {
        if c >= 0.9 { return AppTheme.Colors.primary }
        if c >= 0.7 { return .orange }
        return AppTheme.Colors.error
    }

    // MARK: - Actions
    @State private var solveTask: Task<Void, Never>?

    private func startSolving() {
        guard solveTask == nil else { return }
        guard usage.canSolve else {
            isLoading = false
            showLimitAlert = true
            return
        }
        solveTask = Task {
            await solve()
        }
    }

    private func solve() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await aiService.solve(image: image)
            solution = result
            isLoading = false
            usage.recordSolve()
            autoSave()
            if usage.shouldShowReview {
                try? await Task.sleep(for: .seconds(1.5))
                requestReview()
            }
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
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

    // MARK: - Share Solution
    private func shareSolution() {
        guard let sol = solution else { return }
        let renderer = ImageRenderer(content: ShareableView(solution: sol))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            shareImage = uiImage
            showShareSheet = true
        }
    }

}

// MARK: - Shareable Solution View (for ImageRenderer)
struct ShareableView: View {
    let solution: MathSolution

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "function")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.13, green: 0.77, blue: 0.37))
                Text("MathPro")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text(solution.subject.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(solution.subject.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(solution.subject.color.opacity(0.2))
                    .clipShape(Capsule())
            }

            // Problem
            Text(solution.problem)
                .font(.system(size: 15))
                .foregroundStyle(Color(white: 0.7))

            // Answer
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color(red: 0.13, green: 0.77, blue: 0.37))
                Text(solution.answer)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.13, green: 0.77, blue: 0.37))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Steps summary
            ForEach(solution.steps) { step in
                HStack(alignment: .top, spacing: 10) {
                    Text(verbatim: "\(step.stepNumber)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 24, height: 24)
                        .background(Color(red: 0.13, green: 0.77, blue: 0.37))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        if let expr = step.expression, !expr.isEmpty {
                            Text(expr)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(Color(red: 0.13, green: 0.77, blue: 0.37))
                        }
                    }
                }
            }

            // Footer
            HStack {
                Spacer()
                Text("mathpro.app")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(white: 0.4))
            }
        }
        .padding(24)
        .frame(width: 380)
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Share Sheet (UIKit wrapper)
struct ShareSheetView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = String(localized: "share_watermark")
        return UIActivityViewController(
            activityItems: [image, text],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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

            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.primarySoft, lineWidth: 5)
                    .frame(width: 72, height: 72)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(AppTheme.Colors.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(rotation))

                Image(systemName: steps[currentStep].icon)
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .contentTransition(.symbolEffect(.replace))
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                Text(steps[currentStep].text)
                    .font(AppTheme.Fonts.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.Colors.surface)
                        .frame(width: 200, height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 200 * progress, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }

                Text(verbatim: "\(elapsedSeconds)s")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

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
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 0.96
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                elapsedSeconds += 1

                let maxTime: CGFloat = 30
                progress = min(CGFloat(elapsedSeconds) / maxTime, 0.95)

                let newStep = min(elapsedSeconds / 4, steps.count - 1)
                if newStep != currentStep {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = newStep
                    }
                }

                if elapsedSeconds > 120 { timer.invalidate() }
            }
        }
    }
}
