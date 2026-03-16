import SwiftUI
import PencilKit

/// Apple Pencil or finger canvas for drawing math problems.
struct PencilInputView: View {
    var onSolve: (UIImage) -> Void

    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var isEmpty = true
    @State private var showClearConfirm = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("Draw Your Problem")
                        .font(AppTheme.Fonts.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Spacer()

                    Button {
                        showClearConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(isEmpty ? AppTheme.Colors.textTertiary : AppTheme.Colors.error)
                    }
                    .disabled(isEmpty)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)

                // Canvas
                ZStack {
                    // Grid background (math notebook feel)
                    GeometryReader { geo in
                        Path { path in
                            let spacing: CGFloat = 28
                            var x: CGFloat = spacing
                            while x < geo.size.width {
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: geo.size.height))
                                x += spacing
                            }
                            var y: CGFloat = spacing
                            while y < geo.size.height {
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: geo.size.width, y: y))
                                y += spacing
                            }
                        }
                        .stroke(AppTheme.Colors.divider.opacity(0.4), lineWidth: 0.5)
                    }

                    CanvasRepresentable(
                        canvasView: $canvasView,
                        toolPicker: toolPicker,
                        onChange: { isEmpty = canvasView.drawing.strokes.isEmpty }
                    )
                }
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                .padding(.horizontal, AppTheme.Spacing.md)
                .frame(maxHeight: .infinity)

                // Hint
                if isEmpty {
                    Text("Write your math problem with Apple Pencil or finger")
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, AppTheme.Spacing.sm)
                }

                // Solve button
                Button {
                    solveDrawing()
                } label: {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "sparkles")
                        Text("Show Solution")
                    }
                }
                .primaryButton()
                .disabled(isEmpty)
                .opacity(isEmpty ? 0.4 : 1)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .confirmationDialog("Canvas will be cleared", isPresented: $showClearConfirm) {
            Button("Clear", role: .destructive) {
                canvasView.drawing = PKDrawing()
                isEmpty = true
            }
        }
    }

    private func solveDrawing() {
        let image = canvasView.drawing.image(
            from: canvasView.bounds,
            scale: UIScreen.main.scale
        )
        // Draw on white background (better for AI)
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let final = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: image.size))
            image.draw(at: .zero)
        }
        onSolve(final)
    }
}

// MARK: - UIViewRepresentable for PKCanvasView
struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let toolPicker: PKToolPicker
    var onChange: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput  // Both Pencil and finger
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.delegate = context.coordinator

        // Show tool picker
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)

        DispatchQueue.main.async {
            canvasView.becomeFirstResponder()
        }
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onChange: onChange)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let onChange: () -> Void
        init(onChange: @escaping () -> Void) { self.onChange = onChange }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onChange()
        }
    }
}

#Preview {
    PencilInputView { image in
        print("Solve: \(image.size)")
    }
    .preferredColorScheme(.dark)
}
