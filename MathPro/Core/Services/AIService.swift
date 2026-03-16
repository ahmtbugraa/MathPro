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
        case .invalidImage:           return String(localized: "Image could not be processed.")
        case .networkError(let msg):  return String(localized: "Network error:") + " \(msg)"
        case .invalidResponse:        return String(localized: "Invalid response from server.")
        case .parseError(let msg):    return String(localized: "Response could not be parsed:") + " \(msg)"
        case .apiError(let msg):      return String(localized: "API error:") + " \(msg)"
        }
    }
}

// MARK: - Qwen OpenAI-Compatible Response DTOs
private struct QwenResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
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

    /// Solves the math problem in the image and returns a step-by-step solution.
    nonisolated func solve(image: UIImage) async throws -> MathSolution {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIError.invalidImage
        }

        // Parallel OCR (provides additional context to AI)
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
        Use LaTeX notation for mathematical expressions where appropriate (e.g. \\frac{1}{2}, x^2, \\sqrt{3}).
        """

        // Build user content with image (base64) + optional OCR text
        var userContent: [[String: Any]] = [
            [
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(base64)"
                ]
            ]
        ]

        let textMessage: String
        if !ocrText.isEmpty {
            textMessage = "OCR extracted text (may contain errors): \(ocrText)\nPlease solve the math problem shown in the image. Respond ONLY with JSON."
        } else {
            textMessage = "Please solve the math problem shown in the image. Respond ONLY with JSON."
        }

        userContent.append([
            "type": "text",
            "text": textMessage
        ])

        let body: [String: Any] = [
            "model": Config.qwenModel,
            "max_tokens": 4096,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userContent]
            ]
        ]

        var request = URLRequest(url: Config.qwenAPIURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.qwenAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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

        let qwenResponse = try JSONDecoder().decode(QwenResponse.self, from: data)
        guard let rawText = qwenResponse.choices.first?.message.content else {
            throw AIError.invalidResponse
        }

        // Clean JSON (model may wrap in ```json ... ```)
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
        // Remove thinking tags if present (Qwen thinking mode)
        if let thinkEnd = result.range(of: "</think>") {
            result = String(result[thinkEnd.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if result.hasPrefix("```json") { result = String(result.dropFirst(7)) }
        if result.hasPrefix("```")     { result = String(result.dropFirst(3)) }
        if result.hasSuffix("```")     { result = String(result.dropLast(3)) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
