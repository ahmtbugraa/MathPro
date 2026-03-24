import Foundation
import UIKit

// MARK: - Errors
enum AIError: LocalizedError {
    case invalidImage
    case networkError(String)
    case invalidResponse
    case parseError(String)
    case apiError(String)
    case dailyLimitReached

    var errorDescription: String? {
        switch self {
        case .invalidImage:           return String(localized: "Image could not be processed.")
        case .networkError(let msg):  return String(localized: "Network error:") + " \(msg)"
        case .invalidResponse:        return String(localized: "Invalid response from server.")
        case .parseError(let msg):    return String(localized: "Response could not be parsed:") + " \(msg)"
        case .apiError(let msg):      return String(localized: "API error:") + " \(msg)"
        case .dailyLimitReached:      return String(localized: "daily_limit_reached_error")
        }
    }
}

// MARK: - Qwen OpenAI-Compatible Response DTOs
struct QwenResponse: Decodable {
    let choices: [Choice]
    let error: QwenError?
    let usage: TokenUsage?

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
        let reasoning_content: String?

        var resolvedContent: String {
            if let c = content, !c.isEmpty { return c }
            return reasoning_content ?? ""
        }
    }

    struct QwenError: Decodable {
        let message: String?
        let code: String?
    }

    struct TokenUsage: Decodable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
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

// MARK: - In-Memory Cache
private actor SolutionCache {
    static let shared = SolutionCache()
    private var cache: [String: MathSolution] = [:]
    private let maxEntries = 20

    func get(_ key: String) -> MathSolution? {
        cache[key]
    }

    func set(_ key: String, solution: MathSolution) {
        if cache.count >= maxEntries {
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
        cache[key] = solution
    }
}

// MARK: - Service
struct AIService: Sendable {
    private let ocr = OCRService()

    // MARK: - Solve (Vision Model)

    func solve(image: UIImage) async throws -> MathSolution {
        let resized = resizeIfNeeded(image)

        guard let imageData = resized.jpegData(compressionQuality: Config.jpegQuality) else {
            throw AIError.invalidImage
        }

        // OCR for context + cache key
        let ocrText = (try? await ocr.recognizeText(in: resized)) ?? ""

        // Check cache (same OCR text = same problem → free!)
        let cacheKey = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cacheKey.isEmpty, let cached = await SolutionCache.shared.get(cacheKey) {
            return cached
        }

        let base64 = imageData.base64EncodedString()
        let lang = languageName()
        let level = EducationLevel.saved

        // System prompt with education level context
        let systemPrompt = """
        Expert math tutor. Solve the math problem in the image step by step.
        The student is \(level.promptDescription)

        RULES:
        - Read carefully. Double-check arithmetic. Verify final answer.
        - ALL text in \(lang). Subject field always in English.
        - NEVER use $ signs anywhere in JSON values. No LaTeX delimiters.
        - "problem": describe in plain text. Use words like "x squared" not "x^2".
        - "expression": pure LaTeX without $ signs (e.g. "\\frac{1}{2}" not "$\\frac{1}{2}$").
        - "explanation"/"title"/"answer": plain text only, NO LaTeX, NO $ signs.
        - Adapt explanation complexity to the student's level.
        - Concise steps, max 6. Include verification.

        JSON only:
        {"problem":"...","subject":"Algebra|Arithmetic|Geometry|Trigonometry|Calculus|Statistics|Linear Algebra|Word Problem|Other","answer":"...","confidence":0.95,"steps":[{"stepNumber":1,"title":"...","explanation":"...","expression":"..."}]}
        """

        var userContent: [[String: Any]] = [
            ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
        ]

        let userText = ocrText.isEmpty
            ? "Solve. JSON only."
            : "OCR: \(ocrText.prefix(300))\nSolve. JSON only."

        userContent.append(["type": "text", "text": userText])

        let body: [String: Any] = [
            "model": Config.qwenSolveModel,
            "max_tokens": Config.solveMaxTokens,
            "enable_thinking": false,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userContent]
            ]
        ]

        let rawText = try await makeRequest(body: body, timeout: 60)
        let solution = try parseSolution(from: rawText)

        // Cache result
        if !cacheKey.isEmpty {
            await SolutionCache.shared.set(cacheKey, solution: solution)
        }

        return solution
    }

    // MARK: - Shared Request

    private func makeRequest(body: [String: Any], timeout: TimeInterval) async throws -> String {
        var request = URLRequest(url: Config.qwenAPIURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.qwenAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw AIError.apiError("HTTP \(http.statusCode): \(msg)")
        }

        let qwenResponse: QwenResponse
        do {
            qwenResponse = try JSONDecoder().decode(QwenResponse.self, from: data)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? "unreadable"
            throw AIError.parseError("Decode failed: \(error.localizedDescription)\nRaw: \(raw.prefix(500))")
        }

        if let apiErr = qwenResponse.error {
            throw AIError.apiError(apiErr.message ?? apiErr.code ?? "Unknown")
        }

        guard let rawText = qwenResponse.choices.first?.message.resolvedContent, !rawText.isEmpty else {
            throw AIError.parseError("Empty response")
        }

        return rawText
    }

    // MARK: - Parse Solution

    private func parseSolution(from rawText: String) throws -> MathSolution {
        let jsonString = cleanJSON(rawText)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.parseError("JSON encoding failed")
        }

        // Try strict decode first
        if let dto = try? JSONDecoder().decode(SolutionDTO.self, from: jsonData) {
            return buildSolution(from: dto)
        }

        // Fallback: try to extract what we can from partial/malformed JSON
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIError.parseError(String(localized: "Response could not be parsed:") + " " + String(jsonString.prefix(200)))
        }

        let problem = dict["problem"] as? String ?? ""
        let answer = dict["answer"] as? String ?? "?"
        let subject = dict["subject"] as? String ?? "Other"
        let confidence = dict["confidence"] as? Double ?? 0.9

        var steps: [SolutionStep] = []
        if let stepsArray = dict["steps"] as? [[String: Any]] {
            for s in stepsArray {
                steps.append(SolutionStep(
                    stepNumber: s["stepNumber"] as? Int ?? (steps.count + 1),
                    title: s["title"] as? String ?? "",
                    explanation: s["explanation"] as? String ?? "",
                    expression: s["expression"] as? String
                ))
            }
        }

        // Even if steps are empty or partial, return what we have
        if steps.isEmpty {
            steps = [SolutionStep(stepNumber: 1, title: String(localized: "Answer"), explanation: answer, expression: nil)]
        }

        return MathSolution(
            id: UUID(),
            problem: problem,
            answer: answer,
            steps: steps,
            subject: MathSubject(rawValue: subject) ?? .other,
            createdAt: Date(),
            confidence: confidence
        )
    }

    private func buildSolution(from dto: SolutionDTO) -> MathSolution {
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

    // MARK: - Helpers

    private func resizeIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxDim = Config.maxImageDimension
        guard size.width > maxDim || size.height > maxDim else {
            return image
        }

        let scale: CGFloat
        if size.width > size.height {
            scale = maxDim / size.width
        } else {
            scale = maxDim / size.height
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func languageName() -> String {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return switch code {
        case "tr": "Turkish"
        case "en": "English"
        case "de": "German"
        case "fr": "French"
        case "es": "Spanish"
        case "ar": "Arabic"
        case "zh": "Chinese"
        case "ja": "Japanese"
        case "ko": "Korean"
        case "ru": "Russian"
        case "pt": "Portuguese"
        case "it": "Italian"
        default:   "English"
        }
    }

    private func cleanJSON(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove <think> blocks
        if let thinkEnd = result.range(of: "</think>") {
            result = String(result[thinkEnd.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Remove markdown code fences
        if result.hasPrefix("```json") { result = String(result.dropFirst(7)) }
        if result.hasPrefix("```")     { result = String(result.dropFirst(3)) }
        if result.hasSuffix("```")     { result = String(result.dropLast(3)) }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        // Fix unescaped backslashes in JSON string values (LaTeX like \frac, \geq, etc.)
        // Only fix inside JSON strings — between quotes
        result = fixBackslashesInJSON(result)

        // Remove $ signs from within string values (AI sometimes wraps LaTeX in $...$)
        result = removeDollarSigns(result)

        // Repair truncated JSON (when max_tokens cuts off mid-response)
        result = repairTruncatedJSON(result)

        return result
    }

    /// Fix unescaped backslashes in JSON string values.
    /// JSON only allows: \", \\, \/, \b, \f, \n, \r, \t, \uXXXX
    /// LaTeX like \frac, \geq, \sqrt produce invalid \f, \g, \s — we double-escape them.
    private func fixBackslashesInJSON(_ json: String) -> String {
        var chars = Array(json.unicodeScalars)
        var output: [UnicodeScalar] = []
        let validEscapes: Set<UnicodeScalar> = ["\"", "\\", "/", "b", "f", "n", "r", "t", "u"]
        var inString = false
        var i = 0

        while i < chars.count {
            let c = chars[i]

            if c == "\"" && (i == 0 || chars[i - 1] != "\\") {
                inString.toggle()
                output.append(c)
                i += 1
                continue
            }

            if inString && c == "\\" {
                // Look ahead
                if i + 1 < chars.count {
                    let next = chars[i + 1]
                    if next == "\\" || validEscapes.contains(next) {
                        // Already valid — but check if \f is actually \frac (LaTeX, not form-feed)
                        if next == "f" && i + 2 < chars.count && chars[i + 2] != "\"" && chars[i + 2] != "\\" && chars[i + 2] != "," && chars[i + 2] != "}" {
                            // Likely LaTeX \frac, \forall, etc. — double escape
                            output.append("\\")
                            output.append("\\")
                            i += 1
                            continue
                        }
                        if next == "b" && i + 2 < chars.count {
                            let afterB = chars[i + 2]
                            // \begin, \binom etc. vs actual \b backspace
                            if afterB.properties.isAlphabetic {
                                output.append("\\")
                                output.append("\\")
                                i += 1
                                continue
                            }
                        }
                        if next == "n" && i + 2 < chars.count {
                            let afterN = chars[i + 2]
                            // \neq, \not etc. vs actual \n newline — if followed by a letter, it's LaTeX
                            if afterN.properties.isAlphabetic && afterN != "\"" {
                                output.append("\\")
                                output.append("\\")
                                i += 1
                                continue
                            }
                        }
                        if next == "r" && i + 2 < chars.count {
                            let afterR = chars[i + 2]
                            if afterR.properties.isAlphabetic {
                                output.append("\\")
                                output.append("\\")
                                i += 1
                                continue
                            }
                        }
                        if next == "t" && i + 2 < chars.count {
                            let afterT = chars[i + 2]
                            // \theta, \times vs \t tab
                            if afterT.properties.isAlphabetic {
                                output.append("\\")
                                output.append("\\")
                                i += 1
                                continue
                            }
                        }
                        // Valid escape sequence
                        output.append(c)
                        i += 1
                        continue
                    } else {
                        // Invalid escape like \g, \s, \p, \a, \c, \d, \e, \l, \m, \q, \x, \w, etc.
                        // Double-escape: \ → \\
                        output.append("\\")
                        output.append("\\")
                        i += 1
                        continue
                    }
                }
            }

            output.append(c)
            i += 1
        }

        return String(String.UnicodeScalarView(output))
    }

    /// Attempt to repair truncated JSON (when max_tokens cuts off the response)
    private func repairTruncatedJSON(_ json: String) -> String {
        var result = json

        // If it already parses, return as-is
        if let data = result.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: data)) != nil {
            return result
        }

        // Try closing open strings, arrays, objects
        // Count unmatched brackets
        var inString = false
        var braces = 0
        var brackets = 0
        var lastCharWasBackslash = false

        for ch in result {
            if lastCharWasBackslash {
                lastCharWasBackslash = false
                continue
            }
            if ch == "\\" {
                lastCharWasBackslash = true
                continue
            }
            if ch == "\"" { inString.toggle(); continue }
            if inString { continue }
            if ch == "{" { braces += 1 }
            if ch == "}" { braces -= 1 }
            if ch == "[" { brackets += 1 }
            if ch == "]" { brackets -= 1 }
        }

        // If we're inside a string, close it
        if inString { result += "\"" }

        // Remove trailing comma if present
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix(",") {
            result = String(trimmed.dropLast())
        }

        // Close open brackets and braces
        for _ in 0..<brackets { result += "]" }
        for _ in 0..<braces { result += "}" }

        return result
    }

    /// Remove $ signs from JSON string values (LaTeX delimiters the AI inserts)
    private func removeDollarSigns(_ json: String) -> String {
        var chars = Array(json)
        var output: [Character] = []
        var inString = false
        var i = 0

        while i < chars.count {
            let c = chars[i]
            if c == "\"" && (i == 0 || chars[i - 1] != "\\") {
                inString.toggle()
            }
            // Skip $ signs inside JSON strings
            if inString && c == "$" {
                i += 1
                continue
            }
            output.append(c)
            i += 1
        }

        return String(output)
    }
}
