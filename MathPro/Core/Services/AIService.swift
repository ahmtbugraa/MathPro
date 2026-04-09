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
        You are a world-class mathematician. Solve the math problem in the image with 100% accuracy.\(langInstruction)

        ── IMAGE READING ──
        Read EVERY symbol carefully ONCE at the start. Record the exact equation/problem. Watch for: negative signs vs minus, superscripts vs subscripts, similar digits (1/7, 6/8). If blurry, infer from context. NEVER refuse to solve.
        CRITICAL: Once you have read the problem, do NOT re-read or re-interpret the image in later steps. Use the same numbers throughout ALL steps.
        MULTI-CONDITION PROBLEMS: If the problem gives multiple equations, integrals, or conditions, list ALL of them first. You MUST use every given condition to reach the answer. Do NOT ignore any condition.

        ── SOLVING ──
        1. Identify the problem type and method first.
        2. Solve step by step. Max 6 steps. Be concise.
        3. Double-check arithmetic at EVERY step.
        4. Common errors to avoid: sign errors when distributing negatives, forgetting to flip fractions, (a+b)² ≠ a²+b², order of operations, forgetting ± with square roots.
        5. The VERY LAST step MUST contain the final numerical computation with "= NUMBER" in its expression. For example: "36 - 7 = 29" or "x = 3". NEVER end on a setup step — always finish with the actual arithmetic that produces the answer.
        6. STOP after computing the answer. Do NOT add extra steps for: summary, verification, matching to options, re-reading, or "select the choice". The last step must be computation, not selection.

        ── CALCULUS / INTEGRALS ──
        • For ∫f(g(x))dx: ALWAYS try u-substitution with u=g(x), du=g'(x)dx. Update the integration limits accordingly.
        • For composite expressions like g(f(x)): expand g(f(x)) using the definition of g, then use linearity of integration to split into separate integrals.
        • When multiple integral conditions are given, compute each one separately first, then combine them (e.g. split ∫[a,c] = ∫[a,b] + ∫[b,c]) to find the unknown integral.

        ── EXPLANATION LEVEL ──
        The student is \(level.promptDescription)
        This ONLY affects "explanation" and "title" wording. The math, expressions, and answer are ALWAYS identical regardless of level.

        ── JSON FORMAT (STRICT) ──
        You MUST return ONLY a JSON object. No other text.

        Fields:
        - "problem": max 80 chars, plain text, no LaTeX
        - "subject": one of Algebra|Arithmetic|Geometry|Trigonometry|Calculus|Statistics|Linear Algebra|Word Problem|Other
        - "steps": array of step objects. EVERY step MUST have ALL 4 fields:
          - "stepNumber": integer
          - "title": short title, plain text
          - "explanation": 1-2 sentences, plain text, no LaTeX
          - "expression": MANDATORY LaTeX string, no $ signs. Example: "\\frac{6}{5}x = 4x - 42". NEVER omit, NEVER leave empty string.
        - "confidence": 0.0-1.0, your genuine confidence
        - "answer": see below

        ── ANSWER (MOST IMPORTANT) ──
        The "answer" field must be a SINGLE NUMBER or simple expression. Examples of CORRECT answers: "18", "-3", "17/2", "√5", "x = 3".
        Examples of WRONG answers: "1.2 times 15", "the selling price is 18", "18 TL", "sixty".
        NEVER write words, units, or descriptions in the answer. ONLY the number/expression.
        The answer MUST equal the final result after the last "=" in your last step's expression.
        If the problem has multiple choice options (A, B, C, D, E), your answer MUST exactly match one of the options. If it doesn't match any option, you made an error — go back and fix it.

        {"problem":"...","subject":"...","answer":"NUMBER","confidence":0.0-1.0,"steps":[{"stepNumber":1,"title":"...","explanation":"...","expression":"LaTeX REQUIRED"}]}
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
            maxCompletionTokens: 6000,
            temperature: 0
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
        var steps = dto.steps.map { s in
            SolutionStep(stepNumber: s.stepNumber, title: s.title, explanation: s.explanation, expression: s.expression)
        }
        // Remove junk steps that contradict earlier computation
        steps = sanitizeSteps(steps)
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
        steps = sanitizeSteps(steps)
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

        let finalAnswer = verifiedAnswer(claimed: answer.isEmpty ? "?" : answer, steps: steps)
        return MathSolution(
            id: UUID(), problem: problem, answer: finalAnswer, steps: steps,
            subject: MathSubject(rawValue: subject) ?? .other,
            createdAt: Date(), confidence: 0.7
        )
    }

    // MARK: - Step Sanitization

    /// Remove junk steps: summary/verify/re-read steps that add no value or contradict earlier results.
    /// Then renumber remaining steps sequentially.
    private func sanitizeSteps(_ steps: [SolutionStep]) -> [SolutionStep] {
        guard steps.count > 1 else { return steps }

        let junkTitles = ["final", "verify", "check", "confirm", "summary", "result", "conclusion",
                          "match", "re-read", "reread", "interpret", "intended", "revisit",
                          "select", "choice", "option", "pick",
                          "doğrula", "kontrol", "sonuç", "özet", "seçenek", "eşleştir"]

        // Find the last "real computation" step index
        // A real step is one whose title doesn't match junk patterns
        var lastComputeIdx = steps.count - 1
        for i in stride(from: steps.count - 1, through: 0, by: -1) {
            let titleLower = steps[i].title.lowercased()
            let isJunk = junkTitles.contains(where: { titleLower.contains($0) })
            if !isJunk {
                lastComputeIdx = i
                break
            }
        }

        // Keep steps 0...lastComputeIdx, drop the rest
        let kept = Array(steps.prefix(lastComputeIdx + 1))

        // Renumber sequentially
        return kept.enumerated().map { (i, step) in
            SolutionStep(stepNumber: i + 1, title: step.title, explanation: step.explanation, expression: step.expression)
        }
    }

    // MARK: - Answer Verification

    /// Extract the answer from the steps themselves. Never blindly trust AI's "answer" field.
    private func verifiedAnswer(claimed: String, steps: [SolutionStep]) -> String {
        let cleanClaimed = normalizeForComparison(claimed)
        let claimedIsNumeric = looksLikeNumber(cleanClaimed)

        // 1) Collect numeric results from computation steps (skip "final answer" / "verify" type steps)
        let skipTitles = ["final", "verify", "check", "confirm", "summary", "result", "conclusion",
                          "match", "re-read", "reread", "interpret", "intended", "revisit",
                          "select", "choice", "option", "pick",
                          "doğrula", "kontrol", "sonuç", "özet", "seçenek", "eşleştir"]
        var computeResults: [(value: String, clean: String)] = []
        var allResults: [(value: String, clean: String)] = []

        for step in steps {
            if let extracted = extractFinalResult(from: step) {
                let clean = normalizeForComparison(extracted)
                guard looksLikeNumber(clean) else { continue }

                allResults.append((extracted, clean))

                // Check if this is a "summary/verify" step (not a real computation)
                let titleLower = step.title.lowercased()
                let isSummaryStep = skipTitles.contains(where: { titleLower.contains($0) })
                if !isSummaryStep {
                    computeResults.append((extracted, clean))
                }
            }
        }

        // 2) If no results found, return claimed
        let results = computeResults.isEmpty ? allResults : computeResults
        guard !results.isEmpty else { return claimed }

        // 3) Use the LAST computation step's result as the answer
        //    (the last step that actually computes, not summarizes)
        let bestResult = results.last!

        // 4) If claimed matches, return claimed as-is
        if cleanClaimed == bestResult.clean { return claimed }

        // 5) If claimed is not numeric, or differs from computation, prefer step result
        if !claimedIsNumeric || cleanClaimed != bestResult.clean {
            return latexToPlainText(bestResult.value)
        }

        return claimed
    }

    /// Extract the final result after the last "=" from a step's expression or explanation.
    private func extractFinalResult(from step: SolutionStep?) -> String? {
        guard let step else { return nil }

        let sources: [String] = [step.expression, step.explanation].compactMap {
            guard let s = $0, !s.isEmpty else { return nil }
            return s
        }

        for source in sources {
            guard let lastEquals = source.range(of: "=", options: .backwards) else { continue }
            var result = String(source[lastEquals.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // Strip trailing period
            if result.hasSuffix(".") {
                result = String(result.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            // Remove trailing units/text
            for suffix in [" TL", " cm", " m", " kg", " lt", " dir", " tir"] {
                if result.lowercased().hasSuffix(suffix.lowercased()) {
                    result = String(result.dropLast(suffix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            // Remove trailing comma and everything after (e.g. "18, so..." → "18")
            if let commaIdx = result.firstIndex(of: ",") {
                let before = String(result[..<commaIdx]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !before.isEmpty && looksLikeNumber(normalizeForComparison(before)) {
                    result = before
                }
            }

            if !result.isEmpty && looksLikeNumber(normalizeForComparison(result)) {
                return result
            }
        }
        return nil
    }

    /// Check if a normalized string looks like a number or simple math expression (not words).
    private func looksLikeNumber(_ s: String) -> Bool {
        guard s.contains(where: { $0.isNumber }) else { return false }
        // Reject if it contains common word characters that indicate it's a sentence
        let wordPatterns = ["times", "plus", "minus", "equals", "the", "is", "and", "price", "selling"]
        for word in wordPatterns {
            if s.lowercased().contains(word) { return false }
        }
        return true
    }

    /// Convert a LaTeX expression to readable plain text for the answer field.
    private func latexToPlainText(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Convert \frac{a}{b} → a/b
        let fracPattern = try? NSRegularExpression(pattern: "\\\\frac\\{([^}]*)\\}\\{([^}]*)\\}")
        if let fracPattern {
            s = fracPattern.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: "$1/$2")
        }

        // Convert \sqrt{a} → √a
        s = s.replacingOccurrences(of: "\\sqrt", with: "√")

        // Remove remaining LaTeX commands and braces
        s = s.replacingOccurrences(of: "\\left", with: "")
        s = s.replacingOccurrences(of: "\\right", with: "")
        s = s.replacingOccurrences(of: "\\cdot", with: "·")
        s = s.replacingOccurrences(of: "\\times", with: "×")
        s = s.replacingOccurrences(of: "\\pi", with: "π")
        // Remove any remaining backslash commands
        let cmdPattern = try? NSRegularExpression(pattern: "\\\\[a-zA-Z]+")
        if let cmdPattern {
            s = cmdPattern.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: "")
        }
        s = s.replacingOccurrences(of: "{", with: "")
        s = s.replacingOccurrences(of: "}", with: "")
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Normalize a math expression for comparison by converting to a canonical plain form.
    private func normalizeForComparison(_ text: String) -> String {
        var s = latexToPlainText(text)
        s = s.replacingOccurrences(of: " ", with: "")
        return s.lowercased()
    }

    // MARK: - Helpers

    private func resizeIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxDim: CGFloat = 1024
        guard size.width > maxDim || size.height > maxDim else { return image }
        let scale = size.width > size.height ? maxDim / size.width : maxDim / size.height
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }

    private func languageName() -> String {
        // Locale.preferredLanguages is more reliable than Locale.current in app context
        let preferred = Locale.preferredLanguages.first ?? "en"
        let code = String(preferred.prefix(2))
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
        // Fix LaTeX backslash escaping BEFORE JSON decode:
        // AI often writes \frac instead of \\frac in JSON strings.
        // In JSON, \f = form feed (U+000C), \t = tab, \n = newline, \b = backspace, \r = CR
        // These get decoded as control characters, breaking LaTeX.
        result = repairLaTeXEscaping(result)
        // Remove $ signs from string values
        result = removeDollarSigns(result)
        // Repair truncated JSON
        result = repairTruncatedJSON(result)
        return result
    }

    /// Fix broken LaTeX backslash escaping in JSON strings.
    /// When AI writes \frac instead of \\frac, JSON interprets \f as form feed.
    /// This function finds these broken sequences and restores proper escaping.
    private func repairLaTeXEscaping(_ json: String) -> String {
        let chars = Array(json)
        var output: [Character] = []
        var inString = false
        var i = 0

        // Common LaTeX command prefixes that get broken by JSON escape interpretation:
        // \f → form feed (U+000C) — breaks \frac, \forall, \flat
        // \b → backspace (U+0008) — breaks \beta, \binom, \bar, \boxed
        // \t → tab (U+0009) — breaks \theta, \times, \tan, \text
        // \n → newline (U+000A) — breaks \neq, \neg, \nu
        // \r → carriage return (U+000D) — breaks \rho, \rightarrow, \right
        let controlToBackslash: [Character: Character] = [
            "\u{000C}": "f",  // form feed → \f
            "\u{0008}": "b",  // backspace → \b
            "\u{0009}": "t",  // tab → \t
            "\u{000A}": "n",  // newline → \n
            "\u{000D}": "r",  // carriage return → \r
        ]

        while i < chars.count {
            let c = chars[i]
            if c == "\"" && (i == 0 || chars[i - 1] != "\\") { inString.toggle() }

            if inString, let restored = controlToBackslash[c] {
                // Check if next characters look like a LaTeX command (letter sequence)
                let nextIdx = i + 1
                if nextIdx < chars.count && chars[nextIdx].isLetter {
                    // This was likely a broken LaTeX command: restore \\ + letter
                    output.append("\\")
                    output.append("\\")
                    output.append(restored)
                    i += 1
                    continue
                }
            }

            output.append(c)
            i += 1
        }
        return String(output)
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
