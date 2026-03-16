import SwiftUI

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.viewfinder",
            iconColor: AppTheme.Colors.primary,
            title: "Fotoğrafla & Çöz",
            subtitle: "Matematik problemini çek, saniyeler içinde adım adım çözümünü gör."
        ),
        OnboardingPage(
            icon: "list.number",
            iconColor: .purple,
            title: "Adım Adım Açıklama",
            subtitle: "Her adım detaylı açıklanır. Cevabı değil, nasıl yapıldığını öğren."
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            iconColor: .orange,
            title: "AI Destekli Tutor",
            subtitle: "Claude AI ile güçlendirilmiş — cebir, geometri, kalkülüs ve daha fazlası."
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Atla") {
                            hasSeenOnboarding = true
                        }
                        .font(AppTheme.Fonts.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(AppTheme.Spacing.md)
                    }
                }

                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { i in
                        pageView(pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                Spacer()

                // Dots
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(pages.indices, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? AppTheme.Colors.primary : AppTheme.Colors.divider)
                            .frame(width: i == currentPage ? 20 : 8, height: 8)
                            .clipShape(Capsule())
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.lg)

                // CTA
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Devam" : "Başla")
                }
                .primaryButton()
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(page.iconColor)
            }

            VStack(spacing: AppTheme.Spacing.md) {
                Text(page.title)
                    .font(AppTheme.Fonts.largeTitle)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(AppTheme.Fonts.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
