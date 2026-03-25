import Foundation

// MARK: - API Key Obfuscation
/// XOR-encoded API key — not stored as plain text in binary.
/// Not bulletproof, but prevents trivial `strings` extraction.
enum APIKeyStore {
    // XOR-encoded bytes of the Qwen API key
    private static let encoded: [UInt8] = [
        0xD4, 0xCC, 0x8A, 0x9F, 0xC6, 0x95, 0x93, 0x9E,
        0xC5, 0x9F, 0xC1, 0xC3, 0xC2, 0x91, 0xC6, 0x93,
        0xC6, 0xC1, 0x94, 0xC6, 0x96, 0x96, 0x97, 0xC1,
        0x93, 0x93, 0x9E, 0x91, 0x94, 0xC1, 0xC5, 0x92,
        0x93, 0x96, 0x93
    ]
    private static let mask: UInt8 = 0xA7

    static func deobfuscate() -> String {
        String(encoded.map { Character(UnicodeScalar($0 ^ mask)) })
    }
}

// MARK: - Education Level
enum EducationLevel: String, CaseIterable, Identifiable {
    case elementary  = "elementary"
    case middle      = "middle"
    case high        = "high"
    case university  = "university"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .elementary:  return String(localized: "education_elementary")
        case .middle:      return String(localized: "education_middle")
        case .high:        return String(localized: "education_high")
        case .university:  return String(localized: "education_university")
        }
    }

    var icon: String {
        switch self {
        case .elementary:  return "book.fill"
        case .middle:      return "books.vertical.fill"
        case .high:        return "graduationcap.fill"
        case .university:  return "building.columns.fill"
        }
    }

    var emoji: String {
        switch self {
        case .elementary:  return "📒"
        case .middle:      return "📘"
        case .high:        return "🎓"
        case .university:  return "🏛️"
        }
    }

    /// AI prompt description for explanation level
    var promptDescription: String {
        switch self {
        case .elementary:
            return "an elementary school student (ages 6-10). Use very simple language, short sentences, basic vocabulary. Explain like talking to a child. Use concrete examples."
        case .middle:
            return "a middle school student (ages 11-14). Use clear, simple language. Explain mathematical concepts in everyday terms. Avoid jargon."
        case .high:
            return "a high school student (ages 15-18). Use proper mathematical terminology but still explain clearly. Include relevant formulas and theorems by name."
        case .university:
            return "a university/college student. Use formal mathematical language, rigorous notation, and reference theorems or proofs where appropriate. Be concise and precise."
        }
    }

    static var saved: EducationLevel {
        let raw = UserDefaults.standard.string(forKey: "educationLevel") ?? ""
        return EducationLevel(rawValue: raw) ?? .high
    }

    static func save(_ level: EducationLevel) {
        UserDefaults.standard.set(level.rawValue, forKey: "educationLevel")
    }
}

enum Config {
    // MARK: - API Keys
    static var qwenAPIKey: String {
        ProcessInfo.processInfo.environment["QWEN_API_KEY"]
            ?? APIKeyStore.deobfuscate()
    }

    // MARK: - Qwen API
    static let qwenAPIURL = URL(string: "https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions")!
    static let qwenSolveModel    = "qwen3.5-plus"     // High quality for solving (vision)

    // MARK: - App Limits
    static let freeTrialSolveLimit    = 1       // Free users: 1 solve total (trial), then paywall
    static let premiumDailySolveLimit = 50      // Premium: 50 solves/day

    // MARK: - Cost Optimization
    static let solveMaxTokens    = 2500    // Enough for complex problems with 6 steps
    static let maxImageDimension: CGFloat = 512   // Reduced from 768 — saves ~40% image tokens
    static let jpegQuality: CGFloat = 0.5         // Reduced from 0.6

    // MARK: - RevenueCat
    static let revenueCatAPIKey = "appl_JOtHVgSjsJFWznkspIMVBcTxaNM"
    static let entitlementID = "Premium"
}
