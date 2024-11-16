import Foundation
import ARKit
import RealityKit
import Vision

class ARViewModel: ObservableObject {
    @Published var detectedObject: DetectedObject?
    private var arView: ARView?
    
    struct DetectedObject {
        let name: String
        let translation: String
        let confidence: Float
    }
    
    func setupAR(_ arView: ARView) {
        self.arView = arView
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        setupObjectDetection(arView)
    }
    
    private func setupObjectDetection(_ arView: ARView) {
        // Add observer for AR frame updates
        arView.session.delegate = self
    }
    
    private func processFrame(_ frame: ARFrame) {
        guard let currentFrame = frame.capturedImage else { return }
        
        // Convert CMSampleBuffer to CGImage
        let ciImage = CIImage(cvPixelBuffer: currentFrame)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        // Detect objects using ML Service
        MLService.shared.detectObjects(in: cgImage) { [weak self] objects in
            guard let strongSelf = self,
                  let mostConfidentObject = objects.max(by: { $0.confidence < $1.confidence }) else {
                return
            }
            
            // Translate the detected object name
            TranslationService.shared.translate(
                text: mostConfidentObject.name,
                from: "en",
                to: LanguageViewModel.shared.currentLanguage.rawValue.lowercased()
            ) { translation in
                DispatchQueue.main.async {
                    strongSelf.detectedObject = DetectedObject(
                        name: mostConfidentObject.name,
                        translation: translation ?? "",
                        confidence: mostConfidentObject.confidence
                    )
                }
            }
        }
    }
}

extension ARViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Process every 10th frame to save resources
        if frame.timestamp.truncatingRemainder(dividingBy: 0.3) < 0.03 {
            processFrame(frame)
        }
    }
} 