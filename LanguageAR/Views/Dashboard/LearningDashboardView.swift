import SwiftUI
import Charts

struct LearningDashboardView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var isSharePresented = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Language Selection
                    LanguagePickerView()
                        .padding()
                    
                    // Progress Overview
                    ProgressOverviewCard()
                        .padding(.horizontal)
                    
                    // Learning Stats
                    LearningStatsView(timeFrame: $selectedTimeFrame)
                        .padding(.horizontal)
                    
                    // Recommendations
                    RecommendationsView()
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Learning Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isSharePresented = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $isSharePresented) {
                ShareSheet(activityItems: [
                    ShareManager.shared.shareProgress(
                        progress: languageViewModel.learningProgress,
                        language: languageViewModel.currentLanguage.rawValue
                    )
                ])
            }
        }
    }
}

struct LanguagePickerView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        Picker("Language", selection: $languageViewModel.currentLanguage) {
            ForEach(LanguageViewModel.Language.allCases, id: \.self) { language in
                Text(language.rawValue).tag(language)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct ProgressOverviewCard: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Overview")
                .font(.headline)
            
            HStack(spacing: 20) {
                ProgressStatView(title: "Words", count: 120, total: 500)
                ProgressStatView(title: "Phrases", count: 45, total: 100)
                ProgressStatView(title: "Days", count: 7, total: 30)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct ProgressStatView: View {
    let title: String
    let count: Int
    let total: Int
    
    var progress: Double {
        Double(count) / Double(total)
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(count)")
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
            .frame(width: 60, height: 60)
        }
    }
}

// ShareSheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 