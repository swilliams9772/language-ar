import SwiftUI

struct ContentView: View {
    @StateObject private var languageViewModel = LanguageViewModel()
    
    var body: some View {
        TabView {
            ARLearningView()
                .tabItem {
                    Label("AR Learn", systemImage: "camera.viewfinder")
                }
            
            TextRecognitionView()
                .tabItem {
                    Label("Scan", systemImage: "text.viewfinder")
                }
            
            LearningDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
        }
        .environmentObject(languageViewModel)
    }
} 