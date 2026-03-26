import Foundation
import UIKit
import AIProxy

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

// MARK: - JSON DTO
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

    func get(_ key: String) -> MathSolution? { cache[key] }

    func set(_ key: String, solution: MathSolution) {
        if cache.count >= maxEntries {
            if let firstKey = cache.keys.first { cache.removeValue(forKey: firstKey) }
        }
        cache[key] = solution
    }
}

// MARK: - AIProxy Service
struct AIService: Sendable {

    // AIProxy OpenAI-compatible service
    private let openAIService = AIProxy.openAIService(
        partialKey: "v2|e3e5ff8c|mBJHTwYlsc8vvhFA",
        serviceURL: "https://api.aiproxy.com/960ca237/ca44da3d"
    )

    // MARK: - Solve

    func solve(image: UIImage) async throws -> MathSolution {
        let resized = resizeIfNeeded(image)

        guard let imageData = resized.jpegData(compressionQuality: 0.8) else {
            throw AIError.invalidImage
        }

        let base64 = imageData.base64EncodedString()
        guard let imageURL = URL(string: "data:image/jpeg;base64,\(base64)") else {
            throw AIError.invalidImage
        }
        let lang = languageName()
        let level = EducationLevel.saved

        // Language instruction
        let langInstruction = lang == "English" ? "" : """

        LANGUAGE: You MUST write ALL text fields (problem, answer, title, explanation) in \(lang). \
        This is mandatory. The ONLY exception is the "subject" field which must be in English. \
        Do NOT write in English. Write in \(lang).
        """

        let systemPrompt = """
        You are an expert math tutor. Solve the math problem in the image step by step.
        The student is \(level.promptDescription)\(langInstruction)

        RULES:
        - ALWAYS attempt to solve the problem, even if the image is partially cropped or blurry. Use visible information to infer the full problem.
        - Read the problem VERY carefully. Double-check ALL arithmetic. Verify the final answer by substituting back.
        - If the problem has multiple choice options, verify your answer matches one of them.
        - NEVER say "image is incomplete" or "cannot solve". Always try your best to solve with available information.
        - NEVER use $ signs anywhere in JSON values. No LaTeX delimiters.
        - "problem": SHORT description in plain text (max 80 chars).
        - "expression": pure LaTeX without $ signs (e.g. "\\frac{1}{2}" not "$\\frac{1}{2}$").
        - "explanation"/"title"/"answer": plain text only, NO LaTeX, NO $ signs. Keep concise.
        - Adapt explanation complexity to the student's level.
        - Concise steps, max 5. Each step explanation max 2 sentences.
        - CRITICAL: Response must be COMPLETE valid JSON. Do NOT output anything except JSON.

        ANSWER VERIFICATION (MANDATORY):
        After you finish all steps, look at the FINAL numerical/algebraic result in your LAST step.
        The "answer" field MUST be EXACTLY that final result. Do NOT write a different number.
        If your last step says the result is 20, the answer MUST be "20", NOT "18" or anything else.
        If the problem has multiple choice options, your answer must match one of the options.
        TRIPLE-CHECK: steps result == answer field. If they don't match, FIX the answer field.

        JSON only:
        {"problem":"...","subject":"Algebra|Arithmetic|Geometry|Trigonometry|Calculus|Statistics|Linear Algebra|Word Problem|Other","answer":"...","confidence":0.95,"steps":[{"stepNumber":1,"title":"...","explanation":"...","expression":"..."}]}
        """

        let solveInstruction = lang == "English"
            ? "Solve. JSON only."
            : "Solve. JSON only. Remember: ALL text in \(lang)."

        let requestBody = OpenAIChatCompletionRequestBody(
            model: "gpt-5.4-2026-03-05",
            messages: [
                .system(content: .text(systemPrompt)),
                .user(content: .parts([
                    .imageURL(imageURL, detail: .auto),
                    .text(solveInstruction)
                ]))
            ],
            maxCompletionTokens: 4000,
            temperature: 0.1
        )

        let response: OpenAIChatCompletionResponseBody
        do {
            response = try await openAIService.chatCompletionRequest(
                body: requestBody,
                secondsToWait: 60
            )
        } catch {
            throw AIError.networkError(error.localizedDescription)
        }

        guard let rawText = response.choices.first?.message.content, !rawText.isEmpty else {
            throw AIError.invalidResponse
        }

        return try parseSolution(from: rawText)
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

        // Fallback 1: JSONSerialization
        if let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            return buildFromDict(dict)
        }

        // Fallback 2: regex extraction
        return try regexFallback(from: jsonString)
    }

    private func buildSolution(from dto: SolutionDTO) -> MathSolution {
        let steps = dto.steps.map { s in
            SolutionStep(stepNumber: s.stepNumber, title: s.title, explanation: s.explanation, expression: s.expression)
        }
        let answer = verifiedAnswer(claimed: dto.answer, steps: steps)
        return MathSolution(
            id: UUID(), problem: dto.problem, answer: answer, steps: steps,
            subject: MathSubject(rawValue: dto.subject) ?? .other,
            createdAt: Date(), confidence: dto.confidence ?? 0.9
        )
    }

    private func buildFromDict(_ dict: [String: Any]) -> MathSolution {
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
        if steps.isEmpty {
            steps = [SolutionStep(stepNumber: 1, title: String(localized: "Answer"), explanation: answer, expression: nil)]
        }
        let finalAnswer = verifiedAnswer(claimed: answer, steps: steps)
        return MathSolution(
            id: UUID(), problem: problem, answer: finalAnswer, steps: steps,
            subject: MathSubject(rawValue: subject) ?? .other,
            createdAt: Date(), confidence: confidence
        )
    }

    private func regexFallback(from text: String) throws -> MathSolution {
        func extract(_ key: String) -> String? {
            let pattern = "\"\(key)\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\""
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }

        let problem = extract("problem") ?? ""
        let answer = extract("answer") ?? ""
        let subject = extract("subject") ?? "Other"

        guard !answer.isEmpty || !problem.isEmpty else {
            throw AIError.parseError(String(localized: "Response could not be parsed:") + " " + String(text.prefix(200)))
        }

        var steps: [SolutionStep] = []
        let stepPattern = "\\{[^}]*\"stepNumber\"\\s*:\\s*(\\d+)[^}]*\"title\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"[^}]*\"explanation\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"[^}]*\\}"
        if let stepRegex = try? NSRegularExpression(pattern: stepPattern) {
            let matches = stepRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                let num = Int(text[Range(match.range(at: 1), in: text)!]) ?? (steps.count + 1)
                let title = String(text[Range(match.range(at: 2), in: text)!])
                let explanation = String(text[Range(match.range(at: 3), in: text)!])
                steps.append(SolutionStep(stepNumber: num, title: title, explanation: explanation, expression: nil))
            }
        }
        if steps.isEmpty && !answer.isEmpty {
            steps = [SolutionStep(stepNumber: 1, title: String(localized: "Answer"), explanation: answer, expression: nil)]
        }

        return MathSolution(
            id: UUID(), problem: problem, answer: answer.isEmpty ? "?" : answer, steps: steps,
            subject: MathSubject(rawValue: subject) ?? .other,
            createdAt: Date(), confidence: 0.7
        )
    }

    // MARK: - Answer Verification

    /// Compare the claimed answer with what the last step actually computed.
    /// If the last step's expression contains a clear final result (after "="),
    /// and it differs from the claimed answer, prefer the step's result.
    private func verifiedAnswer(claimed: String, steps: [SolutionStep]) -> String {
        guard let lastStep = steps.last else { return claimed }

        // Try to extract the final result from the last step's expression
        // e.g. "x_1 x_2 = \\frac{2(-7)-3}{2} = -\\frac{17}{2}" → "-\\frac{17}{2}"
        let sources = [lastStep.expression, lastStep.explanation].compactMap { $0 }

        for source in sources {
            // Find the last "=" and take everything after it
            guard let lastEquals = source.range(of: "=", options: .backwards) else { continue }
            let afterEquals = source[lastEquals.upperBound...]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !afterEquals.isEmpty else { continue }

            // Clean both for comparison: strip LaTeX, whitespace
            let cleanClaimed = normalizeForComparison(claimed)
            let cleanStep = normalizeForComparison(afterEquals)

            // If they already match, return claimed as-is
            if cleanClaimed == cleanStep { return claimed }

            // If claimed is empty or clearly different, prefer the step result
            if !cleanStep.isEmpty && cleanClaimed != cleanStep {
                // Return the raw step result (will be displayed/cleaned later)
                return String(afterEquals)
            }
        }

        return claimed
    }

    /// Normalize a math expression for comparison by stripping LaTeX commands and whitespace.
    private func normalizeForComparison(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove common LaTeX
        s = s.replacingOccurrences(of: "\\frac", with: "")
        s = s.replacingOccurrences(of: "\\sqrt", with: "sqrt")
        s = s.replacingOccurrences(of: "\\left", with: "")
        s = s.replacingOccurrences(of: "\\right", with: "")
        s = s.replacingOccurrences(of: "\\", with: "")
        s = s.replacingOccurrences(of: " ", with: "")
        s = s.replacingOccurrences(of: "{", with: "")
        s = s.replacingOccurrences(of: "}", with: "")
        return s.lowercased()
    }

    // MARK: - Helpers

    private func resizeIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxDim: CGFloat = 768
        guard size.width > maxDim || size.height > maxDim else { return image }
        let scale = size.width > size.height ? maxDim / size.width : maxDim / size.height
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }

    private func languageName() -> String {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return switch code {
        case "tr": "Turkish"
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
            result = String(result[thinkEnd.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Remove markdown code fences
        if result.hasPrefix("```json") { result = String(result.dropFirst(7)) }
        if result.hasPrefix("```")     { result = String(result.dropFirst(3)) }
        if result.hasSuffix("```")     { result = String(result.dropLast(3)) }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove $ signs from string values
        result = removeDollarSigns(result)
        // Repair truncated JSON
        result = repairTruncatedJSON(result)
        return result
    }

    private func repairTruncatedJSON(_ json: String) -> String {
        var result = json
        if let data = result.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: data)) != nil { return result }

        var inString = false
        var braces = 0, brackets = 0, lastWasBackslash = false
        for ch in result {
            if lastWasBackslash { lastWasBackslash = false; continue }
            if ch == "\\" { lastWasBackslash = true; continue }
            if ch == "\"" { inString.toggle(); continue }
            if inString { continue }
            if ch == "{" { braces += 1 }
            if ch == "}" { braces -= 1 }
            if ch == "[" { brackets += 1 }
            if ch == "]" { brackets -= 1 }
        }
        if inString { result += "\"" }
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix(",") { result = String(trimmed.dropLast()) }
        for _ in 0..<brackets { result += "]" }
        for _ in 0..<braces { result += "}" }
        return result
    }

    private func removeDollarSigns(_ json: String) -> String {
        let chars = Array(json)
        var output: [Character] = []
        var inString = false
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == "\"" && (i == 0 || chars[i - 1] != "\\") { inString.toggle() }
            if inString && c == "$" { i += 1; continue }
            output.append(c)
            i += 1
        }
        return String(output)
    }
}
