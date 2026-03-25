import Foundation
import SwiftUI

/// Manages daily solve limits and tracks API cost.
@Observable
final class UsageService {
    static let shared = UsageService()

    // MARK: - Persisted State
    @ObservationIgnored @AppStorage("dailySolveCount")    private var _dailyCount: Int = 0
    @ObservationIgnored @AppStorage("lastSolveDate")      private var _lastDate: String = ""
    @ObservationIgnored @AppStorage("totalSolveCount")    private var _totalCount: Int = 0
    @ObservationIgnored @AppStorage("isPremium")          private var _isPremium: Bool = false
    @ObservationIgnored @AppStorage("weeklyAPICost")      private var _weeklyCost: Double = 0
    @ObservationIgnored @AppStorage("costWeekStart")      private var _costWeekStart: String = ""

    private init() {}

    // MARK: - Public API
    var isPremium: Bool { _isPremium }
    var totalSolveCount: Int { _totalCount }

    var dailyCount: Int {
        resetIfNewDay()
        return _dailyCount
    }

    var remaining: Int {
        if _isPremium {
            resetIfNewDay()
            return max(0, Config.premiumDailySolveLimit - _dailyCount)
        } else {
            // Free users: 1 total trial solve
            return max(0, Config.freeTrialSolveLimit - _totalCount)
        }
    }

    var canSolve: Bool {
        if _isPremium {
            return remaining > 0
        } else {
            // Free: only if haven't used the 1 free trial
            return _totalCount < Config.freeTrialSolveLimit
        }
    }

    /// Record a successful solve.
    func recordSolve() {
        resetIfNewDay()
        _dailyCount += 1
        _totalCount += 1
        trackCost(0.004)  // ~$0.004 per solve
    }

    func setpremium(_ value: Bool) {
        _isPremium = value
    }

    var shouldShowReview: Bool {
        _totalCount > 0 && _totalCount % 10 == 0
    }

    /// Estimated weekly cost so far.
    var weeklyCostEstimate: Double {
        resetCostIfNewWeek()
        return _weeklyCost
    }

    // MARK: - Cost Tracking

    private func trackCost(_ amount: Double) {
        resetCostIfNewWeek()
        _weeklyCost += amount
    }

    private func resetCostIfNewWeek() {
        let weekStart = Self.weekStartString()
        if _costWeekStart != weekStart {
            _costWeekStart = weekStart
            _weeklyCost = 0
        }
    }

    // MARK: - Day/Week Reset

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

    private static func weekStartString() -> String {
        let cal = Calendar.current
        let start = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: start)
    }
}
