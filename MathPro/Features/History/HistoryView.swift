import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var solveStore: SolveStore

    @State private var selectedRecord: SolveRecord?
    @State private var searchText = ""

    private var filtered: [SolveRecord] {
        guard !searchText.isEmpty else { return solveStore.records }
        return solveStore.records.filter {
            $0.problemText.localizedCaseInsensitiveContains(searchText) ||
            $0.subject.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                if solveStore.records.isEmpty {
                    emptyState
                } else {
                    recordList
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search by topic or problem...")
        }
        .sheet(item: $selectedRecord) { record in
            HistoryDetailView(record: record)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.Colors.textTertiary)

            Text("No solutions yet")
                .font(AppTheme.Fonts.title2)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Solutions will appear here after solving math problems.")
                .font(AppTheme.Fonts.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    // MARK: - Record List
    private var recordList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(filtered) { record in
                    Button {
                        selectedRecord = record
                    } label: {
                        HistoryRowView(record: record)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            solveStore.delete(record)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }
}

// MARK: - Row
struct HistoryRowView: View {
    let record: SolveRecord

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Thumbnail
            if let data = record.imageData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(record.mathSubject.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: record.mathSubject.icon)
                        .font(.title3)
                        .foregroundStyle(record.mathSubject.color)
                }
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(record.problemText.isEmpty ? String(localized: "Problem") : record.problemText)
                    .font(AppTheme.Fonts.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(record.answer)
                    .font(AppTheme.Fonts.callout)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .lineLimit(1)

                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    HistoryView()
        .environmentObject(SolveStore.shared)
}
