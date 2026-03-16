import SwiftUI
import PhotosUI

struct CameraView: View {
    @State private var vm = CameraViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showSolution = false
    @State private var isCapturing = false

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            if vm.isAuthorized {
                cameraContent
            } else {
                permissionDeniedView
            }
        }
        .task { await vm.setup() }
        .onDisappear { vm.stopSession() }
        .sheet(isPresented: $showSolution) {
            if let image = capturedImage {
                SolutionView(image: image)
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            Task {
                if let item,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                    showSolution = true
                }
            }
        }
    }

    // MARK: - Camera Content
    private var cameraContent: some View {
        ZStack {
            // Live preview
            CameraPreviewView(session: vm.session)
                .ignoresSafeArea()

            // Aim frame overlay
            scanFrame

            // Top bar
            VStack {
                topBar
                Spacer()
                bottomBar
            }
        }
    }

    // MARK: - Scan Frame
    private var scanFrame: some View {
        GeometryReader { geo in
            let width  = geo.size.width * 0.80
            let height = width * 0.55
            let x = (geo.size.width  - width)  / 2
            let y = (geo.size.height - height) / 2

            ZStack {
                // Dimmed overlay
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .frame(width: width, height: height)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )

                // Corner brackets
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .stroke(AppTheme.Colors.primary, lineWidth: 2.5)
                    .frame(width: width, height: height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Hint label
                Text("Matematik problemini çerçeveye al")
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .position(x: geo.size.width / 2, y: y + height + 16)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                vm.toggleFlash()
            } label: {
                Image(systemName: vm.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title2)
                    .foregroundStyle(vm.isFlashOn ? AppTheme.Colors.primary : .white)
                    .padding(AppTheme.Spacing.md)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.xl) {
            // Gallery picker
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }

            // Shutter button
            Button {
                guard !isCapturing else { return }
                isCapturing = true
                vm.capturePhoto { image in
                    isCapturing = false
                    guard let image else { return }
                    capturedImage = image
                    showSolution = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 76, height: 76)
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 86, height: 86)
                    if isCapturing {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .scaleEffect(isCapturing ? 0.92 : 1.0)
            .animation(.spring(response: 0.2), value: isCapturing)

            // Spacer to balance
            Color.clear.frame(width: 52, height: 52)
        }
        .padding(.bottom, AppTheme.Spacing.xxl)
    }

    // MARK: - Permission Denied
    private var permissionDeniedView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.Colors.primary)

            Text("Kamera İzni Gerekli")
                .font(AppTheme.Fonts.title2)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(vm.cameraError ?? "Matematik problemlerini fotoğraflamak için kamera erişimine ihtiyaç var.")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            Button("Ayarları Aç") {
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
    CameraView()
        .preferredColorScheme(.dark)
}
