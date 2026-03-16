import Foundation
import SwiftUI

/// Günlük ücretsiz çözüm limitini yönetir.
/// Premium kullanıcılar için sınırsız erişim sağlar.
@Observable
final class UsageService {
    static let shared = UsageService()

    // MARK: - Persisted State
    @ObservationIgnored
    @AppStorage("dailySolveCount")  private var _dailyCount: Int = 0
    @ObservationIgnored
    @AppStorage("lastSolveDate")    private var _lastDate: String = ""
    @ObservationIgnored
    @AppStorage("totalSolveCount")  private var _totalCount: Int = 0
    @ObservationIgnored
    @AppStorage("isPremium")        private var _isPremium: Bool = false

    private init() {}

    // MARK: - Public API
    var isPremium: Bool { _isPremium }
    var totalSolveCount: Int { _totalCount }

    var dailyCount: Int {
        resetIfNewDay()
        return _dailyCount
    }

    var remaining: Int {
        guard !_isPremium else { return Int.max }
        return max(0, Config.freeDailySolveLimit - dailyCount)
    }

    var canSolve: Bool {
        _isPremium || remaining > 0
    }

    /// Çözüm başarıyla tamamlandıktan sonra çağır.
    func recordSolve() {
        resetIfNewDay()
        _dailyCount += 1
        _totalCount += 1
    }

    /// RevenueCat entitlements kontrolünden sonra çağır.
    func setpremium(_ value: Bool) {
        _isPremium = value
    }

    /// Review prompt gösterilmeli mi?
    var shouldShowReview: Bool {
        // Her 10 çözümde bir göster
        _totalCount > 0 && _totalCount % 10 == 0
    }

    // MARK: - Private
    private func resetIfNewDay() {
        let today = Self.todayString()
        if _lastDate != today {
            _lastDate = today
            _dailyCount = 0
        }
    }

    private static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
