import SwiftUI

/// Shows the full solution for a previously solved problem from history.
struct HistoryDetailView: View {
    let record: SolveRecord

    @Environment(\.dismiss) private var dismiss
    @State private var showFullImage = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Header: Image + Subject ──
                        headerSection

                        // ── Answer Card ──
                        answerCard
                            .padding(.top, 20)

                        // ── Divider ──
                        notebookDivider
                            .padding(.top, 24)
                            .padding(.bottom, 8)

                        // ── Steps Label ──
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
                        let steps = record.steps
                        if !steps.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(steps.enumerated()), id: \.element.id) { idx, step in
                                    StepCardView(
                                        step: step,
                                        isLast: idx == steps.count - 1
                                    )
                                }
                            }
                        } else {
                            Text("No steps available")
                                .font(AppTheme.Fonts.callout)
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                                .padding(.vertical, AppTheme.Spacing.lg)
                        }

                        // ── Footer ──
                        if !steps.isEmpty {
                            completionBadge(stepCount: steps.count)
                                .padding(.top, 20)
                        }

                        // ── Date ──
                        HStack {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(record.createdAt.formatted(date: .long, time: .shortened))
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .padding(.top, 16)

                        Spacer(minLength: AppTheme.Spacing.xxl)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .background(AppTheme.Colors.background)

                // ── Full-screen image overlay ──
                if showFullImage, let data = record.imageData, let img = UIImage(data: data) {
                    fullImageOverlay(image: img)
                        .transition(.opacity)
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
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(spacing: 12) {
            if let data = record.imageData, let img = UIImage(data: data) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showFullImage = true
                    }
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )

                        // Expand icon hint
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .offset(x: -2, y: -2)
                    }
                }
                .accessibilityLabel("View original photo")
                .accessibilityHint("Double tap to see the full photo of the math problem")
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(record.mathSubject.rawValue, systemImage: record.mathSubject.icon)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(record.mathSubject.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(record.mathSubject.color.opacity(0.12))
                    .clipShape(Capsule())

                Text(record.problemText)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(3)
            }

            Spacer()
        }
    }

    // MARK: - Full Image Overlay
    private func fullImageOverlay(image: UIImage) -> some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.92)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showFullImage = false
                    }
                }

            VStack(spacing: 16) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showFullImage = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .accessibilityLabel("Close photo")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Full image — zoomable
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width - 32)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)

                // Problem text under image
                Text(record.problemText)
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    // MARK: - Answer Card
    private var answerCard: some View {
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

            if record.answer.contains("\\") || record.answer.contains("^") || record.answer.contains("_") {
                DisplayMathView(latex: record.answer, fontSize: 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(record.answer)
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

    // MARK: - Completion Badge
    private func completionBadge(stepCount: Int) -> some View {
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
                Text("\(stepCount) steps")
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
}
