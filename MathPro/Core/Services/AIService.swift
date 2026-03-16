import Foundation
import UIKit

// MARK: - Errors
enum AIError: LocalizedError {
    case invalidImage
    case networkError(String)
    case invalidResponse
    case parseError(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:           return "Görsel işlenemedi."
        case .networkError(let msg):  return "Ağ hatası: \(msg)"
        case .invalidResponse:        return "Sunucudan geçersiz yanıt."
        case .parseError(let msg):    return "Yanıt ayrıştırılamadı: \(msg)"
        case .apiError(let msg):      return "API hatası: \(msg)"
        }
    }
}

// MARK: - Response DTOs
private struct ClaudeResponse: Decodable {
    let content: [ContentBlock]
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
}

private struct SolutionDTO: Decodable {
    let problem: String
    let subject: String
    let answer: String
    let steps: [StepDTO]
    let confidence: Double?

    struct StepDTO: Decodable {
        let stepNumber: Int
        let title: String
        let explanation: String
        let expression: String?
    }
}

// MARK: - Service
struct AIService {
    private let ocr = OCRService()

    /// Görüntüdeki matematik problemini çözer ve adım adım çözüm döner.
    nonisolated func solve(image: UIImage) async throws -> MathSolution {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIError.invalidImage
        }

        // Paralel OCR (Claude'a ek bağlam sağlar)
        let ocrText = (try? await ocr.recognizeText(in: image)) ?? ""
        let base64 = imageData.base64EncodedString()

        let systemPrompt = """
        You are an expert math tutor. Analyze the math problem in the image and provide a complete, step-by-step solution.
        Always respond with valid JSON matching exactly this structure (no markdown, no extra text):
        {
          "problem": "transcribed problem statement",
          "subject": "Algebra|Arithmetic|Geometry|Trigonometry|Calculus|Statistics|Linear Algebra|Word Problem|Other",
          "answer": "final answer",
          "confidence": 0.95,
          "steps": [
            {
              "stepNumber": 1,
              "title": "Brief step title",
              "explanation": "Clear explanation of this step",
              "expression": "mathematical expression (optional)"
            }
          ]
        }
        Be thorough with steps. Explain each step clearly for a student.
        """

        var userContent: [[String: Any]] = [
            [
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": base64
                ]
            ]
        ]

        if !ocrText.isEmpty {
            userContent.append([
                "type": "text",
                "text": "OCR extracted text (may contain errors): \(ocrText)\nPlease solve the math problem shown in the image."
            ])
        } else {
            userContent.append([
                "type": "text",
                "text": "Please solve the math problem shown in the image."
            ])
        }

        let body: [String: Any] = [
            "model": Config.claudeModel,
            "max_tokens": 2048,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userContent]
            ]
        ]

        var request = URLRequest(url: Config.claudeAPIURL)
        request.httpMethod = "POST"
        request.setValue(Config.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Config.anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw AIError.apiError("HTTP \(http.statusCode): \(msg)")
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let rawText = claudeResponse.content.first(where: { $0.type == "text" })?.text else {
            throw AIError.invalidResponse
        }

        // JSON'u temizle (Claude bazen ```json ... ``` sarabilir)
        let jsonString = cleanJSON(rawText)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.parseError("JSON encoding failed")
        }

        let dto = try JSONDecoder().decode(SolutionDTO.self, from: jsonData)

        let steps = dto.steps.map { s in
            SolutionStep(
                stepNumber: s.stepNumber,
                title: s.title,
                explanation: s.explanation,
                expression: s.expression
            )
        }

        return MathSolution(
            id: UUID(),
            problem: dto.problem,
            answer: dto.answer,
            steps: steps,
            subject: MathSubject(rawValue: dto.subject) ?? .other,
            createdAt: Date(),
            confidence: dto.confidence ?? 0.9
        )
    }

    private func cleanJSON(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") { result = String(result.dropFirst(7)) }
        if result.hasPrefix("```")    { result = String(result.dropFirst(3)) }
        if result.hasSuffix("```")    { result = String(result.dropLast(3)) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
