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
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                SPTView(scene: model.scene, clearColor: clearColor, viewCameraEntity: model.viewCameraEntity)
                    .gesture(orbitDragGesture)
                    .onLocatedTapGesture { location in
                        if let object = model.pickObjectAt(location, viewportSize: geometry.size) {
                            model.select(object)
                        } else {
                            model.discardSelection()
                        }
                    }
                    .allowsHitTesting(!isNavigating)
                    .onChange(of: colorScheme) { _ in
                        clearColor = UIColor.sceneBgrColor.mtlClearColor
                    }
                
                ui(viewportSize: geometry.size)
            }
        }
        .ignoresSafeArea()
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
            .onChanged { value in
                withAnimation {
                    isNavigating = true
                }
                model.orbit(dragValue: value)
            }
            .onEnded { value in
                withAnimation {
                    isNavigating = false
                }
                model.finishOrbit(dragValue: value)
            }
    }
    
    func zoomDragGesture(viewportSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                withAnimation {
                    isNavigating = true
                }
                model.zoom(dragValue: value, viewportSize: viewportSize)
            }
            .onEnded { value in
                withAnimation {
                    isNavigating = false
                }
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
    
    static let width = 24.0
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
