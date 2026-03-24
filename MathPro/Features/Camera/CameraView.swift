import SwiftUI
import PhotosUI

// MARK: - Photo Transferable (handles all image formats including HEIC)
struct ImageTransferable: Transferable {
    let uiImage: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return ImageTransferable(uiImage: image)
        }
    }

    enum TransferError: Error {
        case importFailed
    }
}

struct CameraView: View {
    @State private var vm = CameraViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var imageToCrop: UIImage?
    @State private var showCrop = false
    @State private var showSolution = false
    @State private var isCapturing  = false
    @State private var shouldSolveAfterCrop = false
    @State private var showHistory = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if vm.isAuthorized {
                cameraContent
            } else {
                permissionDeniedView
            }
        }
        .task { await vm.setup() }
        .onDisappear { vm.stopSession() }
        .fullScreenCover(isPresented: $showCrop) {
            if let img = imageToCrop {
                ImageCropView(
                    image: img,
                    onCropped: { croppedImage in
                        capturedImage = croppedImage
                        shouldSolveAfterCrop = true
                        showCrop = false
                    },
                    onCancel: {
                        imageToCrop = nil
                        shouldSolveAfterCrop = false
                        showCrop = false
                    }
                )
            } else {
                // Safety fallback — dismiss immediately
                Color.clear.onAppear {
                    DispatchQueue.main.async {
                        showCrop = false
                    }
                }
            }
        }
        .onChange(of: showCrop) { oldVal, newVal in
            if oldVal == true && newVal == false && shouldSolveAfterCrop {
                shouldSolveAfterCrop = false
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    showSolution = true
                }
            }
        }
        .sheet(isPresented: $showSolution, onDismiss: {
            imageToCrop = nil
        }) {
            if let image = capturedImage {
                SolutionView(image: image)
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                // Try loading as UIImage transferable first (handles HEIC, RAW, etc.)
                if let image = try? await item.loadTransferable(type: ImageTransferable.self) {
                    imageToCrop = image.uiImage
                    showCrop = true
                } else if let data = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) {
                    // Fallback: load as raw data
                    imageToCrop = image
                    showCrop = true
                }
                selectedPhotoItem = nil
            }
        }
    }

    // MARK: - Camera Content (Full Screen)
    private var cameraContent: some View {
        ZStack {
            CameraPreviewView(session: vm.session)
                .ignoresSafeArea()

            scanFrame

            // Top bar with history, mode switcher, settings, flash
            VStack(spacing: 0) {
                topBar
                Spacer()
                bottomBar
            }
        }
    }

    // MARK: - Scan Frame
    private var scanFrame: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.82
            let h = w * 0.55
            let y = (geo.size.height - h) / 2

            ZStack {
                Color.black.opacity(0.42)
                    .ignoresSafeArea()
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .frame(width: w, height: h)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(AppTheme.Colors.primary, lineWidth: 2.5)
                    .frame(width: w, height: h)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                Text("Frame the math problem")
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .position(x: geo.size.width / 2, y: y + h + 20)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                // History button
                Button { showHistory = true } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Spacer()

                // Flash button
                Button { vm.toggleFlash() } label: {
                    Image(systemName: vm.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(vm.isFlashOn ? AppTheme.Colors.primary : .white)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                // Settings button
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .padding(.top, 8)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                // Gallery picker
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                        Text("Gallery")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                Spacer()

                // Capture button (center, larger)
                Button {
                    guard !isCapturing else { return }
                    isCapturing = true
                    vm.capturePhoto { image in
                        isCapturing = false
                        guard let image else { return }
                        imageToCrop = image
                        showCrop = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 72, height: 72)
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 3)
                            .frame(width: 82, height: 82)
                        if isCapturing {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                    }
                }
                .scaleEffect(isCapturing ? 0.92 : 1.0)
                .animation(.spring(response: 0.2), value: isCapturing)

                Spacer()

                // Invisible spacer to keep capture button centered
                Color.clear
                    .frame(width: 52, height: 52)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.bottom, 24)
        .padding(.top, 12)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.6), .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Permission Denied
    private var permissionDeniedView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.Colors.primary)
            Text("Camera Permission Required")
                .font(AppTheme.Fonts.title2)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(vm.cameraError ?? String(localized: "Camera access is required to photograph math problems."))
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .primaryButton()
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }
}

#Preview {
    CameraView().preferredColorScheme(.dark)
}
