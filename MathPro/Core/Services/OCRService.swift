import Vision
import UIKit

enum OCRError: LocalizedError {
    case noTextFound
    case processingFailed(String)

    var errorDescription: String? {
        switch self {
        case .noTextFound:           return "Görselde metin bulunamadı."
        case .processingFailed(let msg): return "OCR hatası: \(msg)"
        }
    }
}

struct OCRService {
    /// UIImage içindeki metni Vision framework ile tanır.
    /// Claude'a gönderilmeden önce ek bağlam sağlar.
    nonisolated func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.processingFailed("CGImage dönüşümü başarısız")
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: OCRError.processingFailed(error.localizedDescription))
                    return
                }

                let recognized = request.results?
                    .compactMap { ($0 as? VNRecognizedTextObservation)?.topCandidates(1).first?.string }
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    ?? ""

                if recognized.isEmpty {
                    // OCR metni bulamazsa boş string dön — Claude görüntüyü yine de analiz eder
                    continuation.resume(returning: "")
                } else {
                    continuation.resume(returning: recognized)
                }
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US", "tr-TR"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.processingFailed(error.localizedDescription))
            }
        }
    }
}
