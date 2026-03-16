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
                    loadingView
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
        .alert("Günlük Limit Doldu", isPresented: $showLimitAlert) {
            Button("Premium'a Geç") { showPaywall = true }
            Button("Tamam", role: .cancel) { dismiss() }
        } message: {
            Text("Bugün \(Config.freeDailySolveLimit) ücretsiz çözüm hakkını kullandın. Sınırsız çözüm için Premium'a geç.")
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Loading
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.primarySoft, lineWidth: 4)
                    .frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(AppTheme.Colors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                Image(systemName: "function")
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            Text("Çözüm Hesaplanıyor...")
                .font(AppTheme.Fonts.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Adım adım açıklama hazırlanıyor")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Error
    private func errorView(_ msg: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(AppTheme.Colors.error)
            Text("Bir hata oluştu")
                .font(AppTheme.Fonts.title2)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(msg)
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            Button("Tekrar Dene") { Task { await checkLimitAndSolve() } }
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
                        // Kalan hak göstergesi (premium değilse)
                        if !usage.isPremium {
                            Text("\(usage.remaining) hak kaldı")
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
                    Text("CEVAP")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    // KaTeX ile render — düz metin fallback
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
                        Text("ADIM ADIM ÇÖZÜM")
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
            // Review prompt
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
