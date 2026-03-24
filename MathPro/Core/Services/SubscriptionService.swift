import Foundation
import SwiftUI
import RevenueCat

// MARK: - SubscriptionService
@Observable
final class SubscriptionService: NSObject, PurchasesDelegate {
    static let shared = SubscriptionService()

    var isPremium = false
    var isLoading = false
    var errorMessage: String?

    // Current offerings from RevenueCat
    var currentOffering: Offering?
    var weeklyPackage: Package?
    var annualPackage: Package?

    private override init() {
        super.init()
    }

    // MARK: - Configure (call in MathProApp.init)
    func configure() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: Config.revenueCatAPIKey)
        Purchases.shared.delegate = self

        Task {
            await checkEntitlements()
            await fetchOfferings()
        }
    }

    // MARK: - Fetch Offerings
    func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.currentOffering = offerings.current
                self.weeklyPackage = offerings.current?.weekly
                self.annualPackage = offerings.current?.annual
            }
        } catch {
            print("[SubscriptionService] Failed to fetch offerings: \(error)")
        }
    }

    // MARK: - Purchase
    func purchase(package: Package) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if !result.userCancelled {
                let premium = result.customerInfo.entitlements[Config.entitlementID]?.isActive == true
                await MainActor.run {
                    isPremium = premium
                    UsageService.shared.setpremium(premium)
                }
                return premium
            }
            return false
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }

    // MARK: - Restore
    func restore() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let premium = customerInfo.entitlements[Config.entitlementID]?.isActive == true
            await MainActor.run {
                isPremium = premium
                UsageService.shared.setpremium(premium)
            }
            return premium
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }

    // MARK: - Check Entitlements
    func checkEntitlements() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let premium = customerInfo.entitlements[Config.entitlementID]?.isActive == true
            await MainActor.run {
                isPremium = premium
                UsageService.shared.setpremium(premium)
            }
        } catch {
            print("[SubscriptionService] Failed to check entitlements: \(error)")
        }
    }

    // MARK: - PurchasesDelegate
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let premium = customerInfo.entitlements[Config.entitlementID]?.isActive == true
        Task { @MainActor in
            SubscriptionService.shared.isPremium = premium
            UsageService.shared.setpremium(premium)
        }
    }
}

// MARK: - Helper to get localized price from Package
extension Package {
    var localizedPrice: String {
        storeProduct.localizedPriceString
    }

    var localizedPeriod: String {
        guard let period = storeProduct.subscriptionPeriod else { return "" }
        switch period.unit {
        case .week:  return String(localized: "/ week")
        case .month: return String(localized: "/ month")
        case .year:  return String(localized: "/ year")
        default:     return ""
        }
    }

    var hasFreeTrial: Bool {
        storeProduct.introductoryDiscount?.paymentMode == .freeTrial
    }

    var trialDurationText: String? {
        guard let intro = storeProduct.introductoryDiscount,
              intro.paymentMode == .freeTrial else { return nil }
        let days = intro.subscriptionPeriod.value
        let unit = intro.subscriptionPeriod.unit
        switch unit {
        case .day:   return String(format: String(localized: "%d days free"), days)
        case .week:  return String(format: String(localized: "%d weeks free"), days)
        case .month: return String(format: String(localized: "%d months free"), days)
        default:     return nil
        }
    }
}
