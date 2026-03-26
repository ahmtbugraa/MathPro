//
//  MathProApp.swift
//  MathPro
//
//  Created by Ahmet Bugra  on 16.03.2026.
//

import SwiftUI

@main
struct MathProApp: App {
    @StateObject private var solveStore = SolveStore.shared

    init() {
        SubscriptionService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(solveStore)
        }
    }
}
