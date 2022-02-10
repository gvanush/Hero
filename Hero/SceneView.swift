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
    let isRenderingPaused: Bool
    let isNavigationEnabled: Bool
    let isObjectPickingEnabled: Bool
    @GestureState private var isOrbitDragGestureActive = false
    @GestureState private var isZoomDragGestureActive = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    init(model: SceneViewModel, isNavigating: Binding<Bool>, isRenderingPaused: Bool = false,
         isNavigationEnabled: Bool = true, isObjectPickingEnabled: Bool = true) {
        self.model = model
        self._isNavigating = isNavigating
        self.isRenderingPaused = isRenderingPaused
        self.isNavigationEnabled = isNavigationEnabled
        self.isObjectPickingEnabled = isObjectPickingEnabled
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SPTView(scene: model.scene, clearColor: clearColor, viewCameraObject: model.viewCameraObject, isRenderingPaused: isRenderingPaused)
                // NOTE: Adding 'allowsHitTesting' to 'SPTView' will cause its underlying
                // view controller's 'viewWillAppear' to be called on each gesture start,
                // hence creating a separate view on top
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(isNavigationEnabled ? orbitDragGesture : nil)
                    .gesture(isObjectPickingEnabled ? pickGesture(viewportSize: geometry.size) : nil)
                    .allowsHitTesting(isNavigationEnabled && !isNavigating)
                
                navigationControls(geometry: geometry)
                    .visible(isNavigationEnabled && !isNavigating)
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
        .onChange(of: colorScheme) { _ in
            clearColor = UIColor.sceneBgrColor.mtlClearColor
        }
    }
    
    func navigationControls(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0.0) {
            VStack {
                Spacer()
                uiButton(iconName: "camera.metering.center.weighted") {
                    model.focusOn(model.selectedObject!)
                }
                .disabled(!model.isObjectSelected)
            }
            .padding(.leading, 8.0)
            
            Spacer(minLength: 0.0)
            
            VStack {
                Spacer()
                ZoomView()
                    .frame(maxHeight: min(Self.zoomMaxViewHeight, geometry.size.height))
            }
            .contentShape(Rectangle())
            .gesture(zoomDragGesture(viewportSize: geometry.size))
        }
        .padding(.bottom, geometry.size.height > Self.uiBottomPadding ? Self.uiBottomPadding : 0.0)
        .tint(.primary)
    }
    
    func uiButton(iconName: String, action: @escaping (() -> Void)) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .imageScale(.large)
                .frame(maxWidth: 50.0, maxHeight: 50.0, alignment: .center)
        }
        .background(Material.thin)
        .cornerRadius(15.0)
        .shadow(radius: 1.0)
    }
    
    func pickGesture(viewportSize: CGSize) -> some Gesture {
        LocatedTapGesture().onEnded(perform: { location in
            model.selectedObject = model.pickObjectAt(location, viewportSize: viewportSize)
        })
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
    static let uiBottomPadding = 280.0
    static let zoomMaxViewHeight = 250.0
}

fileprivate struct ZoomView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            VLine().stroke(style: Self.lineStrokeStyle)
            Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
            VLine().stroke(style: Self.lineStrokeStyle)
        }
        .background {
            EmptyView()
            .background(Material.thin)
            .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
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
