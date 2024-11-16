import Foundation
import CoreML
import Vision
import CoreData

class LanguageViewModel: ObservableObject {
    @Published var currentLanguage: Language = .spanish
    @Published var learningProgress: [String: Float] = [:]
    @Published var recommendations: [LearningRecommendation] = []
    
    private let context = CoreDataManager.shared.context
    
    init() {
        loadProgress()
    }
    
    private func loadProgress() {
        let request: NSFetchRequest<CDLearningProgress> = CDLearningProgress.fetchRequest()
        request.predicate = NSPredicate(format: "language == %@", currentLanguage.rawValue)
        
        do {
            let progressEntries = try context.fetch(request)
            learningProgress = Dictionary(grouping: progressEntries) { $0.activity ?? "" }
                .mapValues { entries in
                    entries.sorted { $0.date ?? Date() > $1.date ?? Date() }
                        .first?.progress ?? 0.0
                }
        } catch {
            print("Error loading progress: \(error)")
        }
    }
    
    func updateProgress(for activity: String, progress: Float) {
        let cdProgress = CDLearningProgress(context: context)
        cdProgress.id = UUID()
        cdProgress.activity = activity
        cdProgress.progress = progress
        cdProgress.language = currentLanguage.rawValue
        cdProgress.date = Date()
        
        CoreDataManager.shared.save()
        loadProgress()
        generateRecommendations()
    }
    
    private func generateRecommendations() {
        // ML-based recommendation logic using historical data
        let request: NSFetchRequest<CDLearningProgress> = CDLearningProgress.fetchRequest()
        request.predicate = NSPredicate(format: "language == %@", currentLanguage.rawValue)
        
        do {
            let progressHistory = try context.fetch(request)
            // Use progress history to generate recommendations
            // This is where you'd implement your ML logic
        } catch {
            print("Error fetching progress history: \(error)")
        }
    }
} 