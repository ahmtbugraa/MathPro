import SwiftUI

enum AppTheme {

    // MARK: - Colors
    enum Colors {
        static let primary      = Color(red: 0.13, green: 0.77, blue: 0.37)   // #22C55E
        static let primaryDark  = Color(red: 0.08, green: 0.55, blue: 0.25)
        static let primarySoft  = Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.15)

        static let background   = Color(red: 0.05, green: 0.05, blue: 0.05)   // #0D0D0D
        static let surface      = Color(red: 0.11, green: 0.11, blue: 0.12)   // #1C1C1E
        static let surfaceHigh  = Color(red: 0.17, green: 0.17, blue: 0.18)   // #2C2C2E

        static let textPrimary    = Color.white
        static let textSecondary  = Color(white: 0.60)
        static let textTertiary   = Color(white: 0.38)

        static let divider      = Color(white: 0.20)
        static let error        = Color(red: 1.0, green: 0.27, blue: 0.23)
    }

    // MARK: - Typography
    enum Fonts {
        static let largeTitle = Font.system(size: 32, weight: .bold,     design: .rounded)
        static let title      = Font.system(size: 24, weight: .bold,     design: .rounded)
        static let title2     = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline   = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body       = Font.system(size: 16, weight: .regular)
        static let callout    = Font.system(size: 15, weight: .regular)
        static let caption    = Font.system(size: 12, weight: .medium)
        static let math       = Font.system(size: 18, weight: .medium,   design: .monospaced)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 24
        static let full: CGFloat = 999
    }

    // MARK: - Shadows
    enum Shadows {
        static func card(color: Color = .black) -> some View {
            Color.clear.shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - View Modifiers
extension View {
    func primaryButton() -> some View {
        self
            .font(AppTheme.Fonts.headline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
    }

    func secondaryButton() -> some View {
        self
            .font(AppTheme.Fonts.headline)
            .foregroundStyle(AppTheme.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.Colors.primarySoft)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl))
    }

    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
    }
}
