//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.21.
//

import SwiftUI

class SceneViewModel: ObservableObject {
    
    let scene = Scene()
    var viewCameraSphericalCoord = SphericalCoord()
    
    init() {
        setupCamera()
        setupAxis()
        addImages()
    }
    
    private func setupCamera() {
        scene.viewCamera.camera!.near = 0.1
        scene.viewCamera.camera!.far = 1000.0
        scene.viewCamera.camera!.fovy = Float.pi / 3.0
        scene.viewCamera.camera!.orthographicScale = 70.0
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene.viewCamera.transform!.position = viewCameraSphericalCoord.getPosition()
    }
    
    private func setupAxis() {
        let axisHalfLength: Float = 1000.0
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
            
            let imageObject = scene.makeImageObject()
            imageObject.textureRenderer!.texture = texture
            if i == 0 {
                let size = Float(30.0)
                imageObject.textureRenderer!.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                imageObject.transform!.position = simd_float3(0.0, 0.0, 20.0)
            } else {
                
                let sizeRange = Float(10.0)...Float(100.0)
                let width = Float.random(in: sizeRange)
                let height = Float.random(in: sizeRange)
                
                let size = min(width, height) / 2.0
                
                let positionRange = Float(-70.0)...Float(70.0)
                imageObject.textureRenderer!.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                imageObject.transform!.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...300.0))
            }
        }
    }
    
}

struct SceneView: View {
    
    @StateObject var viewModel = SceneViewModel()
    
    let dragGesture = DragGesture(minimumDistance: 0.0)
        .onChanged { value in
            print("changed")
        }
        .onEnded { value in
            print("ended")
        }
    
    var body: some View {
        ZStack {
            SceneViewProxy(scene: viewModel.scene, viewCameraSphericalCoord: viewModel.viewCameraSphericalCoord)
            HStack {
                Spacer()
                ZoomView()
                    .padding(.trailing, Self.margin)
                    .contentShape(Rectangle())
                    .gesture(dragGesture)
            }
        }
    }
    
    static let margin = 8.0
    
    
    struct UIElementShadow: ViewModifier {
        func body(content: Content) -> some View {
            content
                .shadow(color: .black.opacity(0.3), radius: 0.5, x: 0, y: 0)
        }
    }
    static let uiElementBackgroundMaterial = Material.thinMaterial
}

fileprivate struct ZoomView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "plus.magnifyingglass")
            GeometryReader { geometry in
                Path { path in
                    let x = 0.5 * (geometry.size.width - Self.dashWidth)
                    var y = 0.0
                    repeat {
                        path.addRect(CGRect(x: x, y: y, width: Self.dashWidth, height: Self.dashHeight))
                        y += (Self.dashSpacing + Self.dashHeight)
                    } while y + Self.dashHeight < geometry.size.height
                }
                .fill(.black)
            }
            Image(systemName: "minus.magnifyingglass")
        }
        .padding(Self.padding)
        .frame(width: Self.width, height: Self.height, alignment: .center)
        .background(SceneView.uiElementBackgroundMaterial, in: RoundedRectangle(cornerRadius: Self.cornerRadius))
        .sceneViewUIElementShadow()
    }
    
    static let width = 28.0
    static let height = 166.0
    static let padding = 4.0
    static let cornerRadius = 7.0
    static let dashWidth = 4.0
    static let dashHeight = 1.0
    static let dashSpacing = 4.0
    
}

extension View {
    func sceneViewUIElementShadow() -> some View {
        modifier(SceneView.UIElementShadow())
    }
}

struct SceneViewProxy: UIViewControllerRepresentable {
    
    init(scene: Hero.Scene, viewCameraSphericalCoord: SphericalCoord) {
        self.scene = scene
        self.viewCameraSphericalCoord = viewCameraSphericalCoord
    }
    
    func makeUIViewController(context: Context) -> SceneViewController {
        SceneViewController(scene: scene, viewCameraSphericalCoord: viewCameraSphericalCoord)
    }
    
    func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = SceneViewController
    
    let scene: Hero.Scene
    let viewCameraSphericalCoord: SphericalCoord
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
    }
}
