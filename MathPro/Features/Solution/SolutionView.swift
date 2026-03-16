import SwiftUI
import SwiftData

struct SolutionView: View {
    let image: UIImage

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var solution: MathSolution?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isSaved = false

    private let aiService = AIService()

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
                        Button {
                            saveToHistory()
                        } label: {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(isSaved ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .task { await solve() }
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

            Button("Tekrar Dene") {
                Task { await solve() }
            }
            .primaryButton()
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    // MARK: - Solution Content
    private func solutionContent(_ sol: MathSolution) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // Captured image thumbnail
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    .frame(maxWidth: .infinity)

                // Subject badge + problem
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
                    }

                    Text(sol.problem)
                        .font(AppTheme.Fonts.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
                .cardStyle()

                // Answer card
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("CEVAP")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Text(sol.answer)
                        .font(AppTheme.Fonts.title)
                        .foregroundStyle(AppTheme.Colors.primary)
                        .lineLimit(4)
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

                        ForEach(sol.steps) { step in
                            StepCardView(step: step)
                        }
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xxl)
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Actions
    private func solve() async {
        isLoading = true
        errorMessage = nil
        do {
            solution = try await aiService.solve(image: image)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func saveToHistory() {
        guard let sol = solution, !isSaved else { return }
        let record = SolveRecord(from: sol, imageData: image.jpegData(compressionQuality: 0.5))
        modelContext.insert(record)
        isSaved = true

        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Review prompt — 3. başarılı çözümden sonra iste (Faz 2)
    }
}
