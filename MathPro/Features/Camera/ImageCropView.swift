import SwiftUI

/// Full-screen crop overlay that lets the user select a region of the image to solve.
struct ImageCropView: View {
    let image: UIImage
    let onCropped: (UIImage) -> Void
    let onCancel: () -> Void

    // Crop rect in image-space coordinates (normalized 0…1)
    @State private var cropRect = CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.4)

    // Gesture tracking
    @State private var activeEdge: Edge? = nil
    @State private var dragStart: CGPoint = .zero
    @State private var initialCropRect: CGRect = .zero

    // Image display geometry
    @State private var imageFrame: CGRect = .zero

    private let minCropSize: CGFloat = 0.12  // minimum 12% of image dimension
    private let handleSize: CGFloat = 44
    private let edgeThreshold: CGFloat = 30

    enum Edge {
        case topLeft, topRight, bottomLeft, bottomRight, body
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
                    }
                    .onAppear {
                        imageFrame = fitted
                    }
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
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

            Spacer()

            Text("Crop Problem")
                .font(AppTheme.Fonts.headline)
                .foregroundStyle(.white)

            Spacer()

            // Reset crop
            Button {
                withAnimation(.spring(response: 0.3)) {
                    cropRect = CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.4)
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
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

    // MARK: - Crop Border + Corner Handles
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

            // Corner handles
            cornerHandle(at: CGPoint(x: screenCrop.minX, y: screenCrop.minY))
            cornerHandle(at: CGPoint(x: screenCrop.maxX, y: screenCrop.minY))
            cornerHandle(at: CGPoint(x: screenCrop.minX, y: screenCrop.maxY))
            cornerHandle(at: CGPoint(x: screenCrop.maxX, y: screenCrop.maxY))
        }
        .allowsHitTesting(false)
    }

    private func cornerHandle(at point: CGPoint) -> some View {
        Circle()
            .fill(AppTheme.Colors.primary)
            .frame(width: 16, height: 16)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
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

            if nearTop && nearLeft        { activeEdge = .topLeft }
            else if nearTop && nearRight  { activeEdge = .topRight }
            else if nearBottom && nearLeft { activeEdge = .bottomLeft }
            else if nearBottom && nearRight { activeEdge = .bottomRight }
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
        let cgImage = image.cgImage!
        let imgW = CGFloat(cgImage.width)
        let imgH = CGFloat(cgImage.height)

        let pixelRect = CGRect(
            x: cropRect.minX * imgW,
            y: cropRect.minY * imgH,
            width:  cropRect.width  * imgW,
            height: cropRect.height * imgH
        )

        if let cropped = cgImage.cropping(to: pixelRect) {
            return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }

    // MARK: - Helpers
    private func clamp(_ value: CGFloat, min minVal: CGFloat, max maxVal: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minVal), maxVal)
    }
}

#Preview {
    ImageCropView(
        image: UIImage(systemName: "doc.text.image")!,
        onCropped: { _ in },
        onCancel: { }
    )
    .preferredColorScheme(.dark)
}
