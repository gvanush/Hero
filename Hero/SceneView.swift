//
//  MainGraphicsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI
import MetalKit
import Metal

class SceneViewModel: ObservableObject, UIRepresentableObserver {
    
    let scene: Hero.Scene
    lazy var graphicsViewModel = GraphicsViewModel(scene: scene)
    
    init() {
        scene = Hero.Scene()
        graphicsViewModel.renderer.addObserver(self, for: scene)
    }

    deinit {
        graphicsViewModel.renderer.removeObserver(self, for: scene)
    }

    func onUIUpdateRequired() {
        objectWillChange.send()
    }
    
    func setupScene() {
        
        scene.viewCamera.camera.orthographicScale = 70.0
        scene.viewCamera.camera.fovy = Float.pi / 3.0
        
        setupAxis()
        addImages()
        
//        scene.makeLineSegment(point1: SIMD3<Float>(0.0, -10.0, 0.0), point2: SIMD3<Float>(0.0, 10.0, 0.0), point3: SIMD3<Float>(20.0, 10.0, 0.0), thickness: 50, color: SIMD4<Float>.green)
    }
    
    private func setupAxis() {
        let axisHalfLength: Float = 10000.0
        let axisThickness: Float = 5.0
        
        // xAxis
        scene.makeLine(point1: SIMD3<Float>(-axisHalfLength, 0.0, 0.0), point2: SIMD3<Float>(axisHalfLength, 0.0, 0.0), thickness: axisThickness, color: SIMD4<Float>.red)
        
        // zAxis
        scene.makeLine(point1: SIMD3<Float>(0.0, 0.0, -axisHalfLength), point2: SIMD3<Float>(0.0, 0.0, axisHalfLength), thickness: axisThickness, color: SIMD4<Float>.blue)
    }
    
    private func addImages() {
        let sampleImageCount = 5
        let textureLoader = MTKTextureLoader(device: RenderingContext.device())
        
        for i in 0..<sampleImageCount {
            let texture = try! textureLoader.newTexture(name: "sample_image_\(i)", scaleFactor: 1.0, bundle: nil, options: nil)
            let texRatio = Float(texture.width) / Float(texture.height)
            
            let imageObject = scene.makeImage()
            imageObject.imageRenderer.texture = texture
            if i == 0 {
                let size = Float(30.0)
                imageObject.imageRenderer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                imageObject.transform.position = simd_float3(0.0, 0.0, 10)
            } else {
                
                let sizeRange = Float(10.0)...Float(100.0)
                let width = Float.random(in: sizeRange)
                let height = Float.random(in: sizeRange)
                
                let size = min(width, height) / 2.0
                
                let positionRange = Float(-70.0)...Float(70.0)
                imageObject.imageRenderer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                imageObject.transform.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...300.0))
            }
        }
    }
}

struct SceneView: View {
    
    @State private var isNavigating = false
    @State private var isTooleditingModeEnabled = true
    @ObservedObject var model: SceneViewModel
    
    var body: some View {
        ZStack {
            GraphicsViewProxy(model: model.graphicsViewModel, isNavigating: $isNavigating.animation())
                .ignoresSafeArea()
            if let selectedObject = model.scene.selectedObject {
                Inspector(model: InspectorModel(sceneObject: selectedObject), isToolEditingModeEnabled: $isTooleditingModeEnabled)
                    .opacity(isNavigating ? 0.0 : 1.0)
            }
        }
        .statusBar(hidden: isNavigating)
        .preference(key: TopBarVisibilityPreferenceKey.self, value: !isNavigating && isTooleditingModeEnabled)
        .onAppear {
            model.setupScene()
        }
    }
}
