import Foundation

enum Config {
    // MARK: - API Keys
    // Claude API key'ini buraya ekle ya da Xcode Scheme > Environment Variables'a ANTHROPIC_API_KEY ekle
    static var anthropicAPIKey: String {
        ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
            ?? "YOUR_ANTHROPIC_API_KEY_HERE"
    }

    // MARK: - Claude API
    static let claudeAPIURL     = URL(string: "https://api.anthropic.com/v1/messages")!
    static let claudeModel      = "claude-opus-4-6"
    static let anthropicVersion = "2023-06-01"

    // MARK: - App Limits
    static let freeDailySolveLimit = 5

    // MARK: - RevenueCat (Faz 2'de entegre edilecek)
    static let revenueCatAPIKey = "YOUR_REVENUECAT_KEY_HERE"
}
