import Foundation
import Combine
import SwiftUI
import RevenueCat

// MARK: - SubscriptionService
final class SubscriptionService: NSObject, ObservableObject, PurchasesDelegate {
    static let shared = SubscriptionService()

    @Published var isPremium = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Current offerings from RevenueCat
    @Published var currentOffering: Offering?
    @Published var weeklyPackage: Package?
    @Published var annualPackage: Package?

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
            #if DEBUG
            print("[SubscriptionService] Failed to fetch offerings: \(error)")
            #endif
        }
    }

    // MARK: - Purchase
    func purchase(package: Package) async -> Bool {
        await MainActor.run { isLoading = true; errorMessage = nil }
        defer { Task { @MainActor in isLoading = false } }

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
        await MainActor.run { isLoading = true; errorMessage = nil }
        defer { Task { @MainActor in isLoading = false } }

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
            #if DEBUG
            print("[SubscriptionService] Failed to check entitlements: \(error)")
            #endif
        }
    }

    // MARK: - PurchasesDelegate
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let premium = customerInfo.entitlements["Premium"]?.isActive == true
        Task { @MainActor in
            SubscriptionService.shared.isPremium = premium
            UsageService.shared.setpremium(premium)
        }
    }
}

// MARK: - Intro Offer Type
enum IntroOfferType {
    case freeTrial(durationText: String)
    case payAsYouGo(priceText: String, durationText: String)
    case payUpFront(priceText: String, durationText: String)
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

    // MARK: - Intro Offer Detection (supports all App Store Connect variants)

    /// Whether this package has any introductory offer
    var hasIntroOffer: Bool {
        storeProduct.introductoryDiscount != nil
    }

    /// Whether this is specifically a free trial
    var hasFreeTrial: Bool {
        storeProduct.introductoryDiscount?.paymentMode == .freeTrial
    }

    /// Parsed intro offer with all details
    var introOffer: IntroOfferType? {
        guard let intro = storeProduct.introductoryDiscount else { return nil }

        let duration = Self.formatPeriod(value: intro.subscriptionPeriod.value, unit: intro.subscriptionPeriod.unit)

        switch intro.paymentMode {
        case .freeTrial:
            // e.g. "3 gün ücretsiz", "1 hafta ücretsiz"
            return .freeTrial(durationText: duration + " " + String(localized: "free"))

        case .payAsYouGo:
            // e.g. "₺4.99/hafta x 3 ay"
            let price = intro.localizedPriceString
            return .payAsYouGo(
                priceText: price + Self.formatPeriodShort(unit: intro.subscriptionPeriod.unit),
                durationText: String(format: String(localized: "%d_periods"), intro.subscriptionPeriod.value) + " " + String(localized: "intro_period")
            )

        case .payUpFront:
            // e.g. "₺29.99 for 3 months"
            let price = intro.localizedPriceString
            return .payUpFront(
                priceText: price,
                durationText: duration
            )

        default:
            return nil
        }
    }

    /// Short badge text for plan cards (e.g. "3 gün ücretsiz", "₺4.99 ile başla")
    var introBadgeText: String? {
        guard let intro = storeProduct.introductoryDiscount else { return nil }
        let duration = Self.formatPeriod(value: intro.subscriptionPeriod.value, unit: intro.subscriptionPeriod.unit)

        switch intro.paymentMode {
        case .freeTrial:
            return duration + " " + String(localized: "free")
        case .payAsYouGo:
            return intro.localizedPriceString + Self.formatPeriodShort(unit: intro.subscriptionPeriod.unit) + " " + String(localized: "intro_price")
        case .payUpFront:
            return intro.localizedPriceString + " " + String(localized: "for") + " " + duration
        default:
            return nil
        }
    }

    /// Subtitle text for under the plan (e.g. "sonra ₺49.99/hafta", "3 gün ücretsiz, sonra ₺49.99/hafta")
    var introSubtitleText: String? {
        guard let intro = storeProduct.introductoryDiscount else { return nil }
        let duration = Self.formatPeriod(value: intro.subscriptionPeriod.value, unit: intro.subscriptionPeriod.unit)
        let thenPrice = String(localized: "then") + " " + localizedPrice + localizedPeriod

        switch intro.paymentMode {
        case .freeTrial:
            return duration + " " + String(localized: "free") + ", " + thenPrice
        case .payAsYouGo:
            return intro.localizedPriceString + Self.formatPeriodShort(unit: intro.subscriptionPeriod.unit) + ", " + thenPrice
        case .payUpFront:
            return intro.localizedPriceString + " " + String(localized: "for") + " " + duration + ", " + thenPrice
        default:
            return nil
        }
    }

    /// CTA button text based on intro offer
    var ctaButtonText: String {
        guard let intro = storeProduct.introductoryDiscount else {
            return String(localized: "Subscribe Now")
        }
        switch intro.paymentMode {
        case .freeTrial:
            return String(localized: "Start Free Trial")
        case .payAsYouGo, .payUpFront:
            return String(localized: "Start Now")
        default:
            return String(localized: "Subscribe Now")
        }
    }

    // MARK: - Period Formatting Helpers

    private static func formatPeriod(value: Int, unit: SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return value == 1
                ? String(localized: "1_day")
                : String(format: String(localized: "%d_days"), value)
        case .week:
            return value == 1
                ? String(localized: "1_week")
                : String(format: String(localized: "%d_weeks"), value)
        case .month:
            return value == 1
                ? String(localized: "1_month")
                : String(format: String(localized: "%d_months"), value)
        case .year:
            return value == 1
                ? String(localized: "1_year")
                : String(format: String(localized: "%d_years"), value)
        @unknown default:
            return ""
        }
    }

    private static func formatPeriodShort(unit: SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:   return String(localized: "/day_short")
        case .week:  return String(localized: "/week_short")
        case .month: return String(localized: "/month_short")
        case .year:  return String(localized: "/year_short")
        @unknown default: return ""
        }
    }

    // Legacy support
    var trialDurationText: String? {
        guard let intro = storeProduct.introductoryDiscount,
              intro.paymentMode == .freeTrial else { return nil }
        let value = intro.subscriptionPeriod.value
        let unit = intro.subscriptionPeriod.unit
        return Self.formatPeriod(value: value, unit: unit) + " " + String(localized: "free")
    }
}
