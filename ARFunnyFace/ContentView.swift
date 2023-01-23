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
var robot: Experience.Robot!

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
                    self.propID = self.propID >= 3 ? 3 : self.propID + 1
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
        arView.session.delegate = context.coordinator
//
//        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        arView.scene.anchors.removeAll()
        robot = nil
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
            
        case 3: // Robot
            let arAnchor = try! Experience.loadRobot()
            uiView.scene.anchors.append(arAnchor)
            robot = arAnchor
            break
            
        default:
            break
        }
    }
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        var arViewContainer: ARViewContainer
        var isLasersDone = true
        init(_ control: ARViewContainer) {
            arViewContainer = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard robot != nil else { return }
            var faceAnchor: ARFaceAnchor?
            for anchor in anchors {
                if let a = anchor as? ARFaceAnchor {
                    faceAnchor = a
                }
            }
            let blendShapes = faceAnchor?.blendShapes
            let eyeBlinkLeft = blendShapes?[.eyeWideLeft]?.floatValue
            let eyeBlinkRight = blendShapes?[.eyeWideRight]?.floatValue
            let browInnerUp = blendShapes?[.browInnerUp]?.floatValue
            let browLeft  = blendShapes?[.browDownLeft]?.floatValue
            let browRight = blendShapes?[.browDownRight]?.floatValue
            let jawOpen = blendShapes?[.jawOpen]?.floatValue
            
            // 1
            robot.eyeLidL?.orientation = simd_mul(
                // 2
                simd_quatf(angle: Deg2Rad(-120 + (90 * eyeBlinkLeft!)),
                           axis: [1, 0, 0]),
                // 3
                simd_quatf(angle: Deg2Rad((90 * browLeft!) - (30 * browInnerUp!)),
                           axis: [0, 0, 1]))
            // 4
            robot.eyeLidR?.orientation = simd_mul(
                simd_quatf(
                    angle: Deg2Rad(-120 + (90 * eyeBlinkRight!)),
                    axis: [1, 0, 0]),
                simd_quatf(
                    angle: Deg2Rad((-90 * browRight!) - (-30 * browInnerUp!)),
                    axis: [0, 0, 1]))
            
            robot.jaw?.orientation = simd_quatf(
                angle: Deg2Rad(-100 + (60 * jawOpen!)),
                axis: [1, 0, 0])
            
            if (self.isLasersDone == true && jawOpen! > 0.9) {
                self.isLasersDone = false
                robot.notifications.showLasers.post()
                robot.actions.lasersDone.onAction = { _ in
                    self.isLasersDone = true
                }
            }
        }
        
        func Deg2Rad(_ value: Float) -> Float {
            return value * .pi / 180
        }
    }
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler(self)
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
