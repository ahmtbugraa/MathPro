import Foundation
import Combine
import SwiftUI

// MARK: - Domain Model
struct MathSolution: Identifiable {
    let id: UUID
    let problem: String
    let answer: String
    let steps: [SolutionStep]
    let subject: MathSubject
    let createdAt: Date
    let confidence: Double

    static let empty = MathSolution(
        id: UUID(), problem: "", answer: "", steps: [],
        subject: .other, createdAt: Date(), confidence: 0
    )
}

struct SolutionStep: Codable, Identifiable {
    var id: UUID
    let stepNumber: Int
    let title: String
    let explanation: String
    let expression: String?

    init(id: UUID = UUID(), stepNumber: Int, title: String, explanation: String, expression: String? = nil) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.explanation = explanation
        self.expression = expression
    }
}

enum MathSubject: String, Codable, CaseIterable {
    case arithmetic   = "Arithmetic"
    case algebra      = "Algebra"
    case geometry     = "Geometry"
    case trigonometry = "Trigonometry"
    case calculus     = "Calculus"
    case statistics   = "Statistics"
    case linearAlgebra = "Linear Algebra"
    case wordProblem  = "Word Problem"
    case other        = "Other"

    var icon: String {
        switch self {
        case .arithmetic:    return "plus.forwardslash.minus"
        case .algebra:       return "function"
        case .geometry:      return "triangle"
        case .trigonometry:  return "waveform.path"
        case .calculus:      return "infinity"
        case .statistics:    return "chart.bar.fill"
        case .linearAlgebra: return "grid"
        case .wordProblem:   return "text.alignleft"
        case .other:         return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .arithmetic:    return .blue
        case .algebra:       return .purple
        case .geometry:      return .orange
        case .trigonometry:  return .red
        case .calculus:      return .indigo
        case .statistics:    return .teal
        case .linearAlgebra: return .mint
        case .wordProblem:   return .yellow
        case .other:         return .gray
        }
    }
}

// MARK: - Persistence Model (JSON file-based, iOS 16+)
final class SolveRecord: Identifiable, Codable {
    var id: UUID
    var problemText: String
    var subject: String
    var answer: String
    var stepsData: Data?
    var imageData: Data?
    var createdAt: Date

    init(from solution: MathSolution, imageData: Data? = nil) {
        self.id = solution.id
        self.problemText = solution.problem
        self.subject = solution.subject.rawValue
        self.answer = solution.answer
        self.stepsData = try? JSONEncoder().encode(solution.steps)
        self.imageData = imageData
        self.createdAt = solution.createdAt
    }

    var steps: [SolutionStep] {
        guard let data = stepsData else { return [] }
        return (try? JSONDecoder().decode([SolutionStep].self, from: data)) ?? []
    }

    var mathSubject: MathSubject {
        MathSubject(rawValue: subject) ?? .other
    }
}

// MARK: - SolveStore (replaces SwiftData)
final class SolveStore: ObservableObject {
    static let shared = SolveStore()

    @Published private(set) var records: [SolveRecord] = []

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("solve_history.json")
    }()

    private init() {
        load()
    }

    func insert(_ record: SolveRecord) {
        records.insert(record, at: 0)
        save()
    }

    func delete(_ record: SolveRecord) {
        records.removeAll { $0.id == record.id }
        save()
    }

    func deleteAll() {
        records.removeAll()
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([SolveRecord].self, from: data)
        } catch {
            records = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Silent fail — non-critical
        }
    }
}
