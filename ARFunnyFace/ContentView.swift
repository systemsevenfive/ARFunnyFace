//
//  ContentView.swift
//  ARFunnyFace
//
//  Created by Ryan Saunders on 2023-01-22.
//

import ARKit
import SwiftUI
import RealityKit

var arView: ARView!

struct ContentView : View {
    @State var propID: Int = 0
    
    func takeSnapshot() {
        arView.snapshot(saveToHDR: false) { (image) in
            let compressedImage = UIImage(data: (image?.pngData())!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        }
                        
                        }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(propID: $propID).edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                Button(action: {
                    self.propID = self.propID <= 0 ? 0 : self.propID - 1
                }) {
                    Image("PreviousButton").clipShape(Circle())
                }
                Spacer()
                Button(action: {
                    self.takeSnapshot()
                }) {
                    Image("ShutterButton").clipShape(Circle())
                }
                Spacer()
                Button(action: {
                    self.propID = self.propID >= 2 ? 2 : self.propID + 1
                }) {
                    Image("NextButton").clipShape(Circle())
                }
                Spacer()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var propID: Int
    func makeUIView(context: Context) -> ARView {
        
       arView = ARView(frame: .zero)
//
//        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let arConfiguration = ARFaceTrackingConfiguration()
        uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        switch(propID) {
        case 0: // Eyes
            let arAnchor = try! Experience.loadEyes()
            uiView.scene.anchors.append(arAnchor)
            break
            
        case 1: // Glasses
            let arAnchor = try! Experience.loadGlasses()
            uiView.scene.anchors.append(arAnchor)
            break
            
        case 2: // Mustache
            let arAnchor = try! Experience.loadMustache()
            uiView.scene.anchors.append(arAnchor)
            break
            
        default:
            break
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
