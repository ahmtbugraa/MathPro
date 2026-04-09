//
//  ContentView.swift
//  MathPro
//
//  Created by Ahmet Bugra  on 16.03.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showLaunch = true

    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else {
                CameraView()
                    .preferredColorScheme(.dark)
            }

            if showLaunch {
                LaunchScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showLaunch = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SolveStore.shared)
}
