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
        .modelContainer(for: SolveRecord.self, inMemory: true)
}
