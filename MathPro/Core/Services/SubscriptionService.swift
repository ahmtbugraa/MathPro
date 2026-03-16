import Foundation
import SwiftUI

// MARK: - SubscriptionService
// Faz 2: RevenueCat entegrasyonu için iskelet.
//
// KURULUM:
// 1. Xcode → File → Add Package Dependencies
// 2. URL: https://github.com/RevenueCat/purchases-ios
// 3. Version: Up to Next Major (4.x.x)
// 4. Target: MathPro
// 5. Aşağıdaki yorum satırlarını kaldır.

// import RevenueCat

@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    var isPremium = false
    var isLoading = false
    var errorMessage: String?

    private init() {}

    // MARK: - Configure (AppDelegate veya MathProApp'te çağır)
    func configure() {
        // Purchases.logLevel = .debug
        // Purchases.configure(withAPIKey: Config.revenueCatAPIKey)
        Task { await checkEntitlements() }
    }

    // MARK: - Purchase
    func purchase(plan: SubscriptionPlan) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // RevenueCat olmadan test modu:
        await MainActor.run {
            isPremium = true
            UsageService.shared.setpremium(true)
        }

        // GERÇEK UYGULAMA (RevenueCat paketi eklendikten sonra):
        // do {
        //     let offerings = try await Purchases.shared.offerings()
        //     guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == plan.packageId }) else { return }
        //     let result = try await Purchases.shared.purchase(package: package)
        //     await MainActor.run {
        //         isPremium = !result.customerInfo.entitlements["premium"]!.isActive == false
        //         UsageService.shared.setpremium(isPremium)
        //     }
        // } catch {
        //     await MainActor.run { errorMessage = error.localizedDescription }
        // }
    }

    // MARK: - Restore
    func restore() async {
        isLoading = true
        defer { isLoading = false }

        // GERÇEK UYGULAMA:
        // do {
        //     let customerInfo = try await Purchases.shared.restorePurchases()
        //     await MainActor.run {
        //         isPremium = customerInfo.entitlements["premium"]?.isActive == true
        //         UsageService.shared.setpremium(isPremium)
        //     }
        // } catch {
        //     await MainActor.run { errorMessage = error.localizedDescription }
        // }
    }

    // MARK: - Check Entitlements
    func checkEntitlements() async {
        // GERÇEK UYGULAMA:
        // do {
        //     let customerInfo = try await Purchases.shared.customerInfo()
        //     await MainActor.run {
        //         isPremium = customerInfo.entitlements["premium"]?.isActive == true
        //         UsageService.shared.setpremium(isPremium)
        //     }
        // } catch {}
    }
}

// MARK: - Plans
enum SubscriptionPlan: CaseIterable {
    case weeklyTrial, annual, lifetime

    var packageId: String {
        switch self {
        case .weeklyTrial: return "$rc_weekly"
        case .annual:      return "$rc_annual"
        case .lifetime:    return "$rc_lifetime"
        }
    }

    var displayTitle: String {
        switch self {
        case .weeklyTrial: return "3 Gün Bedava"
        case .annual:      return "Yıllık Plan"
        case .lifetime:    return "Ömür Boyu"
        }
    }

    var displayPrice: String {
        switch self {
        case .weeklyTrial: return "ÜCRETSİZ"
        case .annual:      return "₺549"
        case .lifetime:    return "₺999"
        }
    }

    var subtitle: String {
        switch self {
        case .weeklyTrial: return "sonra ₺149,00/hafta"
        case .annual:      return "₺549,00/yıl • ₺10,53/hafta"
        case .lifetime:    return "tek seferlik ödeme"
        }
    }
}
