import Foundation

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
        case .elementary:  return "\u{1F4D2}"
        case .middle:      return "\u{1F4D8}"
        case .high:        return "\u{1F393}"
        case .university:  return "\u{1F3DB}\u{FE0F}"
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
    // MARK: - App Limits
    static let freeTrialSolveLimit    = 0       // Free users: no free solves, subscription required
    static let premiumDailySolveLimit = 50      // Premium: 50 solves/day

    // MARK: - RevenueCat
    static let revenueCatAPIKey = "appl_JOtHVgSjsJFWznkspIMVBcTxaNM"
    static let entitlementID = "Premium"
}
