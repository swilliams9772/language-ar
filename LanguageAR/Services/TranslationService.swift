import Foundation

class TranslationService {
    static let shared = TranslationService()
    
    // Replace with your Google Cloud API key
    private let apiKey = APIConfig.translationAPIKey
    private let baseURL = "https://translation.googleapis.com/language/translate/v2"
    
    private init() {}
    
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?) -> Void) {
        // Create URL components
        guard var components = URLComponents(string: baseURL) else {
            completion(nil)
            return
        }
        
        // Add query parameters
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "source", value: sourceLanguage),
            URLQueryItem(name: "target", value: targetLanguage)
        ]
        
        guard let url = components.url else {
            completion(nil)
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  error == nil,
                  let response = try? JSONDecoder().decode(TranslationResponse.self, from: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(response.data.translations.first?.translatedText)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Response Models
    private struct TranslationResponse: Codable {
        let data: TranslationData
    }
    
    private struct TranslationData: Codable {
        let translations: [Translation]
    }
    
    private struct Translation: Codable {
        let translatedText: String
    }
}

// MARK: - Error Handling
extension TranslationService {
    enum TranslationError: Error {
        case invalidURL
        case invalidResponse
        case apiError(String)
        case networkError(Error)
    }
}

// MARK: - Offline Support
extension TranslationService {
    private var cachedTranslations: [String: [String: String]] = [:] // [sourceText: [targetLanguage: translatedText]]
    
    /// Checks if there's a cached translation available
    private func getCachedTranslation(for text: String, targetLanguage: String) -> String? {
        return cachedTranslations[text]?[targetLanguage]
    }
    
    /// Caches a successful translation
    private func cacheTranslation(text: String, translation: String, targetLanguage: String) {
        if cachedTranslations[text] == nil {
            cachedTranslations[text] = [:]
        }
        cachedTranslations[text]?[targetLanguage] = translation
    }
    
    /// Enhanced translate function with caching
    func translateWithCache(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?) -> Void) {
        // Check cache first
        if let cachedTranslation = getCachedTranslation(for: text, targetLanguage: targetLanguage) {
            completion(cachedTranslation)
            return
        }
        
        // If not in cache, perform online translation
        translate(text: text, from: sourceLanguage, to: targetLanguage) { [weak self] translation in
            if let translation = translation {
                self?.cacheTranslation(text: text, translation: translation, targetLanguage: targetLanguage)
            }
            completion(translation)
        }
    }
}

// MARK: - Language Detection
extension TranslationService {
    func detectLanguage(for text: String, completion: @escaping (String?) -> Void) {
        guard var components = URLComponents(string: "\(baseURL)/detect") else {
            completion(nil)
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: text)
        ]
        
        guard let url = components.url else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  error == nil,
                  let response = try? JSONDecoder().decode(DetectionResponse.self, from: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(response.data.detections.first?.first?.language)
            }
        }
        
        task.resume()
    }
    
    private struct DetectionResponse: Codable {
        let data: DetectionData
    }
    
    private struct DetectionData: Codable {
        let detections: [[Detection]]
    }
    
    private struct Detection: Codable {
        let language: String
        let confidence: Float
    }
} 