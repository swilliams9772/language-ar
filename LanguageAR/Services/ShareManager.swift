import SwiftUI
import UIKit

class ShareManager {
    static let shared = ShareManager()
    private init() {}
    
    // MARK: - Progress Sharing
    func shareProgress(progress: [String: Float], language: String) -> UIActivityViewController {
        // Create progress summary
        let summary = createProgressSummary(progress: progress, language: language)
        
        // Create progress image
        let image = createProgressImage(progress: progress, language: language)
        
        // Items to share
        let items: [Any] = [summary, image].compactMap { $0 }
        
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    // MARK: - Community Content Sharing
    func shareCommunityPost(_ post: CommunityPost) -> UIActivityViewController {
        let text = """
        From LanguageAR Community:
        \(post.authorName) shared:
        \(post.content)
        """
        
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    
    func shareCommunityEvent(_ event: CommunityEvent) -> UIActivityViewController {
        let text = """
        Join us at LanguageAR:
        \(event.title)
        📍 \(event.location)
        📅 \(event.date.formatted())
        
        \(event.description)
        """
        
        let items: [Any] = [text, event.imageURL].compactMap { $0 }
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    // MARK: - Helper Methods
    private func createProgressSummary(progress: [String: Float], language: String) -> String {
        """
        My \(language) Learning Progress on LanguageAR:
        
        📚 Words: \(Int(progress["words"] ?? 0 * 100))%
        💬 Phrases: \(Int(progress["phrases"] ?? 0 * 100))%
        📅 Daily Streak: \(Int(progress["streak"] ?? 0)) days
        
        #LanguageAR #\(language)Learning
        """
    }
    
    private func createProgressImage(progress: [String: Float], language: String) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400))
        
        return renderer.image { context in
            // Background
            UIColor.systemBackground.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            
            let title = "\(language) Learning Progress"
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)
            
            // Progress bars
            drawProgressBars(progress: progress, in: context)
            
            // Logo
            drawAppLogo(in: context)
        }
    }
    
    private func drawProgressBars(progress: [String: Float], in context: UIGraphicsImageRendererContext) {
        let metrics = [
            ("Words", progress["words"] ?? 0),
            ("Phrases", progress["phrases"] ?? 0),
            ("Daily Streak", progress["streak"] ?? 0)
        ]
        
        for (index, metric) in metrics.enumerated() {
            let y = 120 + (index * 60)
            
            // Label
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
            metric.0.draw(at: CGPoint(x: 40, y: y), withAttributes: labelAttributes)
            
            // Background bar
            context.cgContext.setFillColor(UIColor.systemGray5.cgColor)
            context.fill(CGRect(x: 150, y: y, width: 400, height: 20))
            
            // Progress bar
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            context.fill(CGRect(x: 150, y: y, width: CGFloat(metric.1) * 400, height: 20))
            
            // Percentage
            let percentageAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.label
            ]
            "\(Int(metric.1 * 100))%".draw(at: CGPoint(x: 560, y: y), withAttributes: percentageAttributes)
        }
    }
    
    private func drawAppLogo(in context: UIGraphicsImageRendererContext) {
        // Add your app logo drawing code here
        // For now, we'll just draw a simple placeholder
        context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
        context.cgContext.fillEllipse(in: CGRect(x: 520, y: 30, width: 40, height: 40))
    }
} 