import AVFoundation
import UIKit
import SwiftUI

@Observable
final class CameraViewModel: NSObject {

    // MARK: - State
    var capturedImage: UIImage?
    var isFlashOn       = false
    var cameraError: String?
    var isAuthorized    = false

    // MARK: - AVFoundation
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    private var captureCompletion: ((UIImage?) -> Void)?

    override init() {
        super.init()
    }

    // MARK: - Setup
    func setup() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            await MainActor.run { isAuthorized = true }
            configureSession()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run { isAuthorized = granted }
            if granted { configureSession() }
        default:
            await MainActor.run {
                isAuthorized = false
                cameraError = "Kamera erişimi reddedildi. Ayarlar'dan izin verin."
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device)
        else {
            session.commitConfiguration()
            return
        }

        currentDevice = device
        if session.canAddInput(input)  { session.addInput(input)  }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        session.commitConfiguration()

        Task.detached { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        Task.detached { [weak self] in
            self?.session.stopRunning()
        }
    }

    // MARK: - Capture
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Torch
    func toggleFlash() {
        guard let device = currentDevice, device.hasTorch else { return }
        isFlashOn.toggle()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            Task { @MainActor in captureCompletion?(nil) }
            return
        }

        Task { @MainActor in
            captureCompletion?(image)
            captureCompletion = nil
        }
    }
}
