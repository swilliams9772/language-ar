import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let camera: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let previewLayer = camera.getPreviewLayer() {
            previewLayer.frame = view.frame
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 