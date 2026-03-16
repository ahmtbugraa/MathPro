//
//  ContentView.swift
//  MathPro
//
//  Created by Ahmet Buğra  on 16.03.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedTab: Tab = .camera

    enum Tab { case camera, history, settings }

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
                .transition(.opacity)
        } else {
            mainTabView
        }
    }

    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            AppTheme.Colors.background.ignoresSafeArea()

            // Tab content
            Group {
                switch selectedTab {
                case .camera:   CameraView()
                case .history:  HistoryView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "camera.fill",    label: "Solve",    tab: .camera)
            tabItem(icon: "clock.fill",     label: "History",  tab: .history)
            tabItem(icon: "gearshape.fill", label: "Settings", tab: .settings)
        }
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.xl)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 0.5),
            alignment: .top
        )
    }

    private func tabItem(icon: String, label: String, tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .symbolEffect(.bounce, value: selectedTab == tab)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? AppTheme.Colors.primary : AppTheme.Colors.textTertiary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SolveRecord.self, inMemory: true)
}
