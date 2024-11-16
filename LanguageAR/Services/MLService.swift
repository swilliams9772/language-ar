import Vision
import CoreML

class MLService {
    static let shared = MLService()
    private init() {}
    
    // MARK: - Object Detection
    lazy var objectDetectionModel: VNCoreMLModel? = {
        do {
            // Using YOLOv3 model - you'll need to download and add this to your project
            let config = MLModelConfiguration()
            let model = try YOLOv3(configuration: config)
            return try VNCoreMLModel(for: model.model)
        } catch {
            print("Failed to load object detection model: \(error)")
            return nil
        }
    }()
    
    // MARK: - Text Recognition
    func detectText(in image: CGImage, completion: @escaping (String?) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            completion(text)
        }
        
        // Configure text recognition for better accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: image)
        try? handler.perform([request])
    }
    
    func detectObjects(in image: CGImage, completion: @escaping ([DetectedObject]) -> Void) {
        guard let model = objectDetectionModel else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard error == nil,
                  let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }
            
            let detectedObjects = results.compactMap { observation -> DetectedObject? in
                guard let label = observation.labels.first else { return nil }
                return DetectedObject(
                    name: label.identifier,
                    confidence: label.confidence,
                    boundingBox: observation.boundingBox
                )
            }
            
            completion(detectedObjects)
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        try? handler.perform([request])
    }
}

struct DetectedObject {
    let name: String
    let confidence: Float
    let boundingBox: CGRect
} 