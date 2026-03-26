//
//  ContentView.swift
//  MathPro
//
//  Created by Ahmet Bugra  on 16.03.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
                .transition(.opacity)
        } else {
            CameraView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SolveStore.shared)
}
