import SwiftUI
import PhotosUI

struct CameraView: View {
    enum InputMode { case camera, pencil }

    @State private var vm = CameraViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showSolution = false
    @State private var isCapturing  = false
    @State private var inputMode: InputMode = .camera

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Mode switcher
                modeSwitcher

                // Content
                if inputMode == .camera {
                    if vm.isAuthorized {
                        cameraContent
                    } else {
                        permissionDeniedView
                    }
                } else {
                    PencilInputView { image in
                        capturedImage = image
                        showSolution  = true
                    }
                }
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
                   let data  = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                    showSolution  = true
                }
            }
        }
    }

    // MARK: - Mode Switcher
    private var modeSwitcher: some View {
        HStack(spacing: 0) {
            modeButton("Camera", icon: "camera.fill", mode: .camera)
            modeButton("Drawing", icon: "pencil.tip", mode: .pencil)
        }
        .padding(4)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private func modeButton(_ label: LocalizedStringKey, icon: String, mode: InputMode) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { inputMode = mode }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).fontWeight(.semibold)
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(inputMode == mode ? .black : AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(inputMode == mode ? AppTheme.Colors.primary : Color.clear)
            .clipShape(Capsule())
        }
    }

    // MARK: - Camera Content
    private var cameraContent: some View {
        ZStack {
            CameraPreviewView(session: vm.session)
                .ignoresSafeArea()
            scanFrame
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
            let w = geo.size.width * 0.82
            let h = w * 0.55
            let x = (geo.size.width  - w) / 2
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
                    .position(x: geo.size.width / 2, y: y + h + 16)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button { vm.toggleFlash() } label: {
                Image(systemName: vm.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title2)
                    .foregroundStyle(vm.isFlashOn ? AppTheme.Colors.primary : .white)
                    .padding(AppTheme.Spacing.md)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.xs)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.xl) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }

            Button {
                guard !isCapturing else { return }
                isCapturing = true
                vm.capturePhoto { image in
                    isCapturing = false
                    guard let image else { return }
                    capturedImage = image
                    showSolution  = true
                }
            } label: {
                ZStack {
                    Circle().fill(AppTheme.Colors.primary).frame(width: 76, height: 76)
                    Circle().stroke(.white, lineWidth: 3).frame(width: 86, height: 86)
                    if isCapturing { ProgressView().tint(.white) }
                }
            }
            .scaleEffect(isCapturing ? 0.92 : 1.0)
            .animation(.spring(response: 0.2), value: isCapturing)

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
