import SwiftUI

/// Full-screen crop overlay that lets the user select a region of the image to solve.
struct ImageCropView: View {
    let image: UIImage
    let onCropped: (UIImage) -> Void
    let onCancel: () -> Void

    // Crop rect in image-space coordinates (normalized 0…1)
    @State private var cropRect = CGRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9)

    // Gesture tracking
    @State private var activeEdge: Edge? = nil
    @State private var dragStart: CGPoint = .zero
    @State private var initialCropRect: CGRect = .zero

    // Image display geometry
    @State private var imageFrame: CGRect = .zero

    // Hint animation
    @State private var showHint = true

    private let minCropSize: CGFloat = 0.08  // minimum 8% — small enough for single question
    private let handleSize: CGFloat = 44
    private let edgeThreshold: CGFloat = 36
    private let defaultCropRect = CGRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9)

    enum Edge {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
        case body
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Image + crop overlay
                GeometryReader { geo in
                    let fitted = fittedRect(imageSize: image.size, in: geo.size)

                    ZStack {
                        // Original image
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: fitted.width, height: fitted.height)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)

                        // Dark overlay outside crop
                        cropOverlay(fitted: fitted, containerSize: geo.size)

                        // Crop border + handles
                        cropBorder(fitted: fitted, containerSize: geo.size)

                        // Hint text
                        if showHint {
                            hintLabel(fitted: fitted, containerSize: geo.size)
                        }
                    }
                    .onAppear {
                        imageFrame = fitted
                        // Hide hint after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showHint = false
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                if showHint {
                                    withAnimation { showHint = false }
                                }
                                handleDrag(value: value, fitted: fitted, containerSize: geo.size)
                            }
                            .onEnded { _ in
                                activeEdge = nil
                            }
                    )
                }

                // Bottom bar
                bottomBar
            }
        }
        .statusBarHidden()
    }

    // MARK: - Hint Label
    private func hintLabel(fitted: CGRect, containerSize: CGSize) -> some View {
        let screenCrop = cropToScreen(fitted: fitted, containerSize: containerSize)

        return Text("Select the question to solve")
            .font(AppTheme.Fonts.callout)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.black.opacity(0.7))
            .clipShape(Capsule())
            .position(x: screenCrop.midX, y: screenCrop.midY)
            .transition(.opacity)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Cancel crop")

            Spacer()

            Text("Crop Problem")
                .font(AppTheme.Fonts.headline)
                .foregroundStyle(.white)

            Spacer()

            // Reset crop
            Button {
                withAnimation(.spring(response: 0.3)) {
                    cropRect = defaultCropRect
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Reset crop area")
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Skip crop — use full image
            Button {
                onCropped(image)
            } label: {
                Text("Full Image")
                    .font(AppTheme.Fonts.headline)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.Colors.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
            }
            .accessibilityLabel("Use full image")
            .accessibilityHint("Double tap to solve without cropping")

            // Confirm crop
            Button {
                let cropped = cropImage()
                onCropped(cropped)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "crop")
                        .font(.body)
                        .fontWeight(.semibold)
                    Text("Solve")
                        .font(AppTheme.Fonts.headline)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppTheme.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
            }
            .accessibilityLabel("Crop and solve")
            .accessibilityHint("Double tap to crop the selected area and solve")
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(Color.black)
    }

    // MARK: - Crop Overlay (dark areas outside selection)
    private func cropOverlay(fitted: CGRect, containerSize: CGSize) -> some View {
        let screenCrop = cropToScreen(fitted: fitted, containerSize: containerSize)

        return Canvas { context, size in
            // Full dark overlay
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(0.55))
            )
            // Clear the crop area
            context.blendMode = .destinationOut
            context.fill(
                Path(roundedRect: screenCrop, cornerRadius: 4),
                with: .color(.white)
            )
        }
        .allowsHitTesting(false)
        .compositingGroup()
    }

    // MARK: - Crop Border + Handles
    private func cropBorder(fitted: CGRect, containerSize: CGSize) -> some View {
        let screenCrop = cropToScreen(fitted: fitted, containerSize: containerSize)

        return ZStack {
            // Border
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppTheme.Colors.primary, lineWidth: 2)
                .frame(width: screenCrop.width, height: screenCrop.height)
                .position(x: screenCrop.midX, y: screenCrop.midY)

            // Grid lines (rule of thirds)
            Path { path in
                let thirdW = screenCrop.width / 3
                let thirdH = screenCrop.height / 3
                for i in 1...2 {
                    let x = screenCrop.minX + thirdW * CGFloat(i)
                    path.move(to: CGPoint(x: x, y: screenCrop.minY))
                    path.addLine(to: CGPoint(x: x, y: screenCrop.maxY))

                    let y = screenCrop.minY + thirdH * CGFloat(i)
                    path.move(to: CGPoint(x: screenCrop.minX, y: y))
                    path.addLine(to: CGPoint(x: screenCrop.maxX, y: y))
                }
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)

            // Corner handles (L-shaped brackets)
            cornerBracket(at: screenCrop, corner: .topLeft)
            cornerBracket(at: screenCrop, corner: .topRight)
            cornerBracket(at: screenCrop, corner: .bottomLeft)
            cornerBracket(at: screenCrop, corner: .bottomRight)

            // Edge handles (small bars on each edge midpoint)
            edgeHandle(
                at: CGPoint(x: screenCrop.midX, y: screenCrop.minY),
                horizontal: true
            )
            edgeHandle(
                at: CGPoint(x: screenCrop.midX, y: screenCrop.maxY),
                horizontal: true
            )
            edgeHandle(
                at: CGPoint(x: screenCrop.minX, y: screenCrop.midY),
                horizontal: false
            )
            edgeHandle(
                at: CGPoint(x: screenCrop.maxX, y: screenCrop.midY),
                horizontal: false
            )
        }
        .allowsHitTesting(false)
    }

    /// L-shaped corner bracket
    private func cornerBracket(at rect: CGRect, corner: Edge) -> some View {
        let bracketLen: CGFloat = 20
        let lineWidth: CGFloat = 3.5

        let point: CGPoint
        let xDir: CGFloat
        let yDir: CGFloat

        switch corner {
        case .topLeft:
            point = CGPoint(x: rect.minX, y: rect.minY)
            xDir = 1; yDir = 1
        case .topRight:
            point = CGPoint(x: rect.maxX, y: rect.minY)
            xDir = -1; yDir = 1
        case .bottomLeft:
            point = CGPoint(x: rect.minX, y: rect.maxY)
            xDir = 1; yDir = -1
        case .bottomRight:
            point = CGPoint(x: rect.maxX, y: rect.maxY)
            xDir = -1; yDir = -1
        default:
            point = .zero; xDir = 0; yDir = 0
        }

        return Path { path in
            // Horizontal arm
            path.move(to: point)
            path.addLine(to: CGPoint(x: point.x + bracketLen * xDir, y: point.y))
            // Vertical arm
            path.move(to: point)
            path.addLine(to: CGPoint(x: point.x, y: point.y + bracketLen * yDir))
        }
        .stroke(AppTheme.Colors.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }

    /// Small bar handle at edge midpoints
    private func edgeHandle(at point: CGPoint, horizontal: Bool) -> some View {
        Capsule()
            .fill(AppTheme.Colors.primary)
            .frame(
                width: horizontal ? 32 : 4,
                height: horizontal ? 4 : 32
            )
            .position(x: point.x, y: point.y)
    }

    // MARK: - Drag Handling
    private func handleDrag(value: DragGesture.Value, fitted: CGRect, containerSize: CGSize) {
        let screenCrop = cropToScreen(fitted: fitted, containerSize: containerSize)
        let location = value.startLocation

        // Determine which edge/corner to drag on first touch
        if activeEdge == nil {
            initialCropRect = cropRect
            dragStart = value.startLocation

            let nearTop    = abs(location.y - screenCrop.minY) < edgeThreshold
            let nearBottom = abs(location.y - screenCrop.maxY) < edgeThreshold
            let nearLeft   = abs(location.x - screenCrop.minX) < edgeThreshold
            let nearRight  = abs(location.x - screenCrop.maxX) < edgeThreshold

            let inHorizontal = location.x > screenCrop.minX - edgeThreshold &&
                               location.x < screenCrop.maxX + edgeThreshold
            let inVertical   = location.y > screenCrop.minY - edgeThreshold &&
                               location.y < screenCrop.maxY + edgeThreshold

            // Corners first (higher priority)
            if nearTop && nearLeft         { activeEdge = .topLeft }
            else if nearTop && nearRight   { activeEdge = .topRight }
            else if nearBottom && nearLeft  { activeEdge = .bottomLeft }
            else if nearBottom && nearRight { activeEdge = .bottomRight }
            // Then edges
            else if nearTop && inHorizontal    { activeEdge = .top }
            else if nearBottom && inHorizontal { activeEdge = .bottom }
            else if nearLeft && inVertical     { activeEdge = .left }
            else if nearRight && inVertical    { activeEdge = .right }
            // Then body drag
            else if screenCrop.contains(location) { activeEdge = .body }
            else { return }
        }

        let dx = (value.location.x - dragStart.x) / fitted.width
        let dy = (value.location.y - dragStart.y) / fitted.height

        var newRect = initialCropRect

        switch activeEdge {
        case .topLeft:
            newRect.origin.x    = clamp(initialCropRect.minX + dx, min: 0, max: initialCropRect.maxX - minCropSize)
            newRect.origin.y    = clamp(initialCropRect.minY + dy, min: 0, max: initialCropRect.maxY - minCropSize)
            newRect.size.width  = initialCropRect.maxX - newRect.origin.x
            newRect.size.height = initialCropRect.maxY - newRect.origin.y

        case .topRight:
            newRect.origin.y    = clamp(initialCropRect.minY + dy, min: 0, max: initialCropRect.maxY - minCropSize)
            newRect.size.width  = clamp(initialCropRect.width + dx, min: minCropSize, max: 1 - initialCropRect.minX)
            newRect.size.height = initialCropRect.maxY - newRect.origin.y

        case .bottomLeft:
            newRect.origin.x    = clamp(initialCropRect.minX + dx, min: 0, max: initialCropRect.maxX - minCropSize)
            newRect.size.width  = initialCropRect.maxX - newRect.origin.x
            newRect.size.height = clamp(initialCropRect.height + dy, min: minCropSize, max: 1 - initialCropRect.minY)

        case .bottomRight:
            newRect.size.width  = clamp(initialCropRect.width + dx, min: minCropSize, max: 1 - initialCropRect.minX)
            newRect.size.height = clamp(initialCropRect.height + dy, min: minCropSize, max: 1 - initialCropRect.minY)

        case .top:
            newRect.origin.y    = clamp(initialCropRect.minY + dy, min: 0, max: initialCropRect.maxY - minCropSize)
            newRect.size.height = initialCropRect.maxY - newRect.origin.y

        case .bottom:
            newRect.size.height = clamp(initialCropRect.height + dy, min: minCropSize, max: 1 - initialCropRect.minY)

        case .left:
            newRect.origin.x   = clamp(initialCropRect.minX + dx, min: 0, max: initialCropRect.maxX - minCropSize)
            newRect.size.width = initialCropRect.maxX - newRect.origin.x

        case .right:
            newRect.size.width = clamp(initialCropRect.width + dx, min: minCropSize, max: 1 - initialCropRect.minX)

        case .body:
            newRect.origin.x = clamp(initialCropRect.minX + dx, min: 0, max: 1 - initialCropRect.width)
            newRect.origin.y = clamp(initialCropRect.minY + dy, min: 0, max: 1 - initialCropRect.height)

        case nil:
            break
        }

        cropRect = newRect
    }

    // MARK: - Coordinate Conversion
    private func cropToScreen(fitted: CGRect, containerSize: CGSize) -> CGRect {
        let offsetX = (containerSize.width  - fitted.width)  / 2
        let offsetY = (containerSize.height - fitted.height) / 2
        return CGRect(
            x: offsetX + cropRect.minX * fitted.width,
            y: offsetY + cropRect.minY * fitted.height,
            width:  cropRect.width  * fitted.width,
            height: cropRect.height * fitted.height
        )
    }

    private func fittedRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        let scale = min(containerSize.width / imageSize.width,
                        containerSize.height / imageSize.height)
        let w = imageSize.width  * scale
        let h = imageSize.height * scale
        return CGRect(x: 0, y: 0, width: w, height: h)
    }

    // MARK: - Crop Image
    private func cropImage() -> UIImage {
        // First normalize the image orientation so pixel data matches what the user sees
        let normalized = normalizeOrientation(image)

        guard let cgImage = normalized.cgImage else { return image }
        let imgW = CGFloat(cgImage.width)
        let imgH = CGFloat(cgImage.height)

        let pixelRect = CGRect(
            x: cropRect.minX * imgW,
            y: cropRect.minY * imgH,
            width:  cropRect.width  * imgW,
            height: cropRect.height * imgH
        )

        if let cropped = cgImage.cropping(to: pixelRect) {
            return UIImage(cgImage: cropped, scale: normalized.scale, orientation: .up)
        }
        return image
    }

    /// Re-draw the image with orientation applied so CGImage pixels match visual layout.
    private func normalizeOrientation(_ img: UIImage) -> UIImage {
        guard img.imageOrientation != .up else { return img }
        let size = img.size
        UIGraphicsBeginImageContextWithOptions(size, false, img.scale)
        img.draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()
        return normalized
    }

    // MARK: - Helpers
    private func clamp(_ value: CGFloat, min minVal: CGFloat, max maxVal: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minVal), maxVal)
    }
}

#Preview {
    ImageCropView(
        image: UIImage(systemName: "doc.text.image") ?? UIImage(),
        onCropped: { _ in },
        onCancel: { }
    )
    .preferredColorScheme(.dark)
}
