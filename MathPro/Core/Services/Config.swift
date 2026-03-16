import Foundation

enum Config {
    // MARK: - API Keys
    // Qwen API key: Xcode Scheme > Environment Variables'a QWEN_API_KEY ekle
    // veya Settings ekranından gir
    static var qwenAPIKey: String {
        ProcessInfo.processInfo.environment["QWEN_API_KEY"]
            ?? UserDefaults.standard.string(forKey: "apiKey")
            ?? "sk-8a249b8fde6a4af3a110f44963fb5414"
    }

    // MARK: - Qwen API
    static let qwenAPIURL = URL(string: "https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions")!
    static let qwenModel  = "qwen3.5-plus"

    // MARK: - App Limits
    static let freeDailySolveLimit = 5

    // MARK: - RevenueCat
    static let revenueCatAPIKey = "YOUR_REVENUECAT_KEY_HERE"
}
