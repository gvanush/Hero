//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.21.
//

import SwiftUI


struct SceneViewConst {
    static let zoomViewMaxHeight = 200.0
    static let uiBgrMaterial = Material.thin
    static let uiPadding = 8.0
    static let uiButtonSize = 50.0
}

struct SceneView: View {
    
    @ObservedObject var model: SceneViewModel
    @Binding var isNavigating: Bool
    
    private(set) var isRenderingPaused = false
    private(set) var lookCategories = LookCategories.all
    private(set) var isNavigationEnabled = true
    private(set) var isSelectionEnabled = true
    @GestureState private var isOrbitDragGestureActive = false
    @GestureState private var isZoomDragGestureActive = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    init(model: SceneViewModel, uiSafeAreaInsets: EdgeInsets, isNavigating: Binding<Bool>) {
        self.model = model
        self._isNavigating = isNavigating
    }
    
    func navigationEnabled(_ enabled: Bool) -> SceneView {
        var view = self
        view.isNavigationEnabled = enabled
        return view
    }
    
    func renderingPaused(_ paused: Bool) -> SceneView {
        var view = self
        view.isRenderingPaused = paused
        return view
    }
    
    func selectionEnabled(_ enabled: Bool) -> SceneView {
        var view = self
        view.isSelectionEnabled = enabled
        return view
    }
    
    func lookCategories(_ categories: LookCategories) -> SceneView {
        var view = self
        view.lookCategories = categories
        return view
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SPTView(scene: model.scene, clearColor: clearColor, viewCameraEntity: model.viewCameraObject.entity)
                    .renderingPaused(isRenderingPaused)
                    .lookCategories(lookCategories.rawValue)
                // NOTE: Adding 'allowsHitTesting' to 'SPTView' will cause its underlying
                // view controller's 'viewWillAppear' to be called on each gesture start,
                // hence creating a separate view on top
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(isNavigationEnabled ? orbitDragGesture : nil)
                    .gesture(isSelectionEnabled ? pickGesture(viewportSize: geometry.size) : nil)
                    .allowsHitTesting(isNavigationEnabled && !isNavigating)
                
                ZStack {
                    zoomControl(geometry: geometry)
                    
                    VStack {
                        Spacer()
                        focusButton()
                    }
                    .padding(.bottom, 310.0)
                    
                }
                .padding(SceneViewConst.uiPadding)
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
    
    func zoomControl(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ZoomView()
                    .frame(maxHeight: SceneViewConst.zoomViewMaxHeight)
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.trailing, -SceneViewConst.uiPadding)
            .gesture(zoomDragGesture(viewportSize: geometry.size))
        }
    }
    
    
    
    func focusButton() -> some View {
        HStack(spacing: 0.0) {
            VStack {
                Spacer()
                SceneUIToggle(isOn: $model.isFocusing, offStateIconName: "camera.metering.center.weighted.average", onStateIconName: "camera.metering.partial")
            }
            Spacer()
        }
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
                .background(SceneViewConst.uiBgrMaterial)
            .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
        }
        .frame(maxWidth: Self.width, maxHeight: .infinity)
        .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black.opacity(0.0)], startPoint: .bottom, endPoint: .top))
    }
    
    static let width = 30.0
    static let lineStrokeStyle = StrokeStyle(lineWidth: 4, dash: [1, 4])
}

struct SelectedObjectUI: ViewModifier {
    
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.objectSelectionColor.opacity(0.6), lineWidth: 1.0)
                    .padding(-0.5)
            }
    }
}

extension View {
    func selectedObjectUI(cornerRadius: CGFloat) -> some View {
        modifier(SelectedObjectUI(cornerRadius: cornerRadius))
    }
}

struct SceneView_Previews: PreviewProvider {
    
    struct SceneViewContainer: View {
        
        @StateObject var model = SceneViewModel()
        
        var body: some View {
            SceneView(model: model, uiSafeAreaInsets: .init(), isNavigating: .constant(false))
        }
    }
    
    static var previews: some View {
        SceneViewContainer()
    }
}
