import AVFoundation
import SwiftUI
import Vision

class CameraViewModel: NSObject, ObservableObject {
    @Published var recognizedText: String?
    @Published var isProcessing = false
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_queue"))
        
        captureSession.addInput(input)
        captureSession.addOutput(output)
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let captureSession = captureSession else { return nil }
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isProcessing,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        isProcessing = true
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            isProcessing = false
            return
        }
        
        MLService.shared.detectText(in: cgImage) { [weak self] detectedText in
            guard let text = detectedText else {
                DispatchQueue.main.async {
                    self?.isProcessing = false
                }
                return
            }
            
            // Translate detected text
            TranslationService.shared.translate(
                text: text,
                from: "en",
                to: LanguageViewModel.shared.currentLanguage.rawValue.lowercased()
            ) { translation in
                DispatchQueue.main.async {
                    self?.recognizedText = translation
                    self?.isProcessing = false
                }
            }
        }
    }
} 