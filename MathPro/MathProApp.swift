//
//  MathProApp.swift
//  MathPro
//
//  Created by Ahmet Buğra  on 16.03.2026.
//

import SwiftUI
import SwiftData

@main
struct MathProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: SolveRecord.self)
        }
    }
}
