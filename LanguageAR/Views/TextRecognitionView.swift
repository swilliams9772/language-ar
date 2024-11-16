import SwiftUI
import Vision

struct TextRecognitionView: View {
    @StateObject private var camera = CameraViewModel()
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Point camera at text to translate")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
                
                if let recognizedText = camera.recognizedText {
                    TranslationView(text: recognizedText)
                }
            }
        }
    }
} 