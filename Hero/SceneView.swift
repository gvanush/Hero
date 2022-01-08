//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.21.
//

import SwiftUI

struct SceneView: View {
    
    @ObservedObject var model: SceneViewModel
    @Binding var isNavigating: Bool
    @GestureState private var isOrbitDragGestureActive = false
    @GestureState private var isZoomDragGestureActive = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                SPTView(scene: model.scene, clearColor: clearColor, viewCameraObject: model.viewCameraObject)
                    .gesture(orbitDragGesture)
                    .onLocatedTapGesture { location in
                        model.selectedObject = model.pickObjectAt(location, viewportSize: geometry.size)
                    }
                    // WARNING: This is causing frame drop when isNavigating changes
                    // frequently in a short period of time
                    .allowsHitTesting(!isNavigating)
                    .onChange(of: colorScheme) { _ in
                        clearColor = UIColor.sceneBgrColor.mtlClearColor
                    }
                
                ui(viewportSize: geometry.size)
            }
        }
        .onChange(of: isOrbitDragGestureActive) { newValue in
            isNavigating = newValue
            if !newValue {
                model.cancelOrbit()
            }
        }
        .onChange(of: isZoomDragGestureActive) { newValue in
            isNavigating = newValue
            if !newValue {
                model.cancelZoom()
            }
        }
    }
    
    func ui(viewportSize: CGSize) -> some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    ZoomView()
                        .frame(maxHeight: max(geometry.size.height - 2 * Self.uiBottomPadding, 0))
                    Spacer()
                }
                .contentShape(Rectangle())
                .gesture(zoomDragGesture(viewportSize: viewportSize))
                .opacity(isNavigating ? 0.0 : 1.0)
            }
        }
    }
    
    var orbitDragGesture: some Gesture {
        DragGesture()
            .updating($isOrbitDragGestureActive, body: { _, state, _ in
                state = true
            })
            .onChanged { value in
                model.orbit(dragValue: value)
            }
            .onEnded { value in
                model.finishOrbit(dragValue: value)
            }
    }
    
    func zoomDragGesture(viewportSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($isZoomDragGestureActive, body: { _, state, _ in
                state = true
            })
            .onChanged { value in
                model.zoom(dragValue: value, viewportSize: viewportSize)
            }
            .onEnded { value in
                model.finishZoom(dragValue: value, viewportSize: viewportSize)
            }
    }
    
    static let margin = 8.0
    static let uiBottomPadding = 260.0
    static let uiElementBorderLineWidth = 0.5
    static let uiElementBackgroundMaterial = Material.thinMaterial
}

fileprivate struct ZoomView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            VLine().stroke(style: Self.lineStrokeStyle)
            Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
            VLine().stroke(style: Self.lineStrokeStyle)
        }
        .frame(maxWidth: Self.width, maxHeight: .infinity)
        .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black.opacity(0.0)], startPoint: .bottom, endPoint: .top))
    }
    
    static let width = 30.0
    static let lineStrokeStyle = StrokeStyle(lineWidth: 4, dash: [1, 4])
}

struct SceneView_Previews: PreviewProvider {
    
    struct SceneViewContainer: View {
        
        @StateObject var model = SceneViewModel()
        
        var body: some View {
            SceneView(model: model, isNavigating: .constant(false))
        }
    }
    
    static var previews: some View {
        SceneViewContainer()
    }
}
