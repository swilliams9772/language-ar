import SwiftUI
import ARKit
import RealityKit

struct ARLearningView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Point camera at objects to learn words")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
                
                if let detectedObject = arViewModel.detectedObject {
                    ObjectLabelView(object: detectedObject)
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arViewModel.setupAR(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
} 