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
    lazy var graphicsViewModel = GraphicsViewModel(scene: scene, isNavigating: Binding(get: {
        self.isNavigating
    }, set: { (value) in
        self.isNavigating = value
    }) )
    
    @Published var isInspectorVisible = true
    var isNavigating: Bool = false {
        willSet {
            isTopBarVisible = !newValue
            isInspectorVisible = !newValue
            isStatusBarVisible = !newValue
        }
    }
    @Binding var isTopBarVisible: Bool
    @Binding var isStatusBarVisible: Bool
    
    init(isTopBarVisible: Binding<Bool>, isStatusBarVisible: Binding<Bool>) {
        scene = Hero.Scene()
        _isTopBarVisible = isTopBarVisible
        _isStatusBarVisible = isStatusBarVisible
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
        addLayers()
        
    }
    
    private func setupAxis() {
        let axisHalfLength: Float = 100.0
        let axisThickness: Float = 4.0
        let xAxis = LineRenderer(point1: SIMD3<Float>(-axisHalfLength, 0.0, 0.0), point2: SIMD3<Float>(axisHalfLength, 0.0, 0.0), thickness: axisThickness, color: SIMD4<Float>.red)
        scene.add(xAxis)
        
        let zAxis = LineRenderer(point1: SIMD3<Float>(0.0, 0.0, -axisHalfLength), point2: SIMD3<Float>(0.0, 0.0, axisHalfLength), thickness: axisThickness, color: SIMD4<Float>.blue)
        scene.add(zAxis)
    }
    
    private func addLayers() {
        let sampleImageCount = 5
        let textureLoader = MTKTextureLoader(device: RenderingContext.device())
        
        for i in 0..<sampleImageCount {
            let texture = try! textureLoader.newTexture(name: "sample_image_\(i)", scaleFactor: 1.0, bundle: nil, options: nil)
            let texRatio = Float(texture.width) / Float(texture.height)
            
            let layer = Layer()
            layer.texture = texture
            if i == 0 {
                let size = Float(30.0)
                layer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                layer.transform.position = simd_float3.zero
            } else {
                
                let sizeRange = Float(10.0)...Float(100.0)
                let width = Float.random(in: sizeRange)
                let height = Float.random(in: sizeRange)
                
                let size = min(width, height) / 2.0
                
                let positionRange = Float(-70.0)...Float(70.0)
                layer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                layer.transform.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...300.0))
            }
            scene.add(layer)
        }
    }
}

struct SceneView: View {
    
    @ObservedObject var model: SceneViewModel
    
    var body: some View {
        ZStack {
            GraphicsViewProxy(model: model.graphicsViewModel)
                .ignoresSafeArea()
            if let selectedObject = model.scene.selectedObject {
                Inspector(model: InspectorModel(sceneObject: selectedObject, isTopBarVisible: $model.isTopBarVisible))
                    .opacity(model.isInspectorVisible ? 1.0 : 0.0)
            }
        }
        .onAppear {
            model.setupScene()
        }
    }
}
