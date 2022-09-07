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

struct SceneView<BV>: View where BV: View {
    
    @ObservedObject var model: SceneViewModel
    let uiSafeAreaInsets: EdgeInsets
    @Binding var isNavigating: Bool
    let bottomView: () -> BV
    
    private(set) var isRenderingPaused = false
    private(set) var lookCategories = LookCategories.all
    private(set) var isNavigationEnabled = true
    private(set) var isSelectionEnabled = true
    @GestureState private var isOrbitDragGestureActive = false
    @GestureState private var isZoomDragGestureActive = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    @State private var uiSteadySafeAreaInsets = EdgeInsets()
    
    init(model: SceneViewModel, uiSafeAreaInsets: EdgeInsets, isNavigating: Binding<Bool>, @ViewBuilder bottomView: @escaping () -> BV = { EmptyView() }) {
        self.model = model
        self.uiSafeAreaInsets = uiSafeAreaInsets
        self.bottomView = bottomView
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
                    VStack(spacing: 0.0) {
                        if let name = model.selectedObjectMetadata?.name {
                            Text(name)
                                .font(.subheadline)
                                .foregroundColor(.secondaryLabel)
                                .frame(height: 30)
                                .padding(.horizontal, 8.0)
                                .background(SceneViewConst.uiBgrMaterial)
                                .cornerRadius(9.0)
                                .selectedObjectUI(cornerRadius: 9.0)
                                .offset(y: isNavigating ? -uiSteadySafeAreaInsets.top : 0.0)
                        }
                        Spacer()
                        ZStack(alignment: .bottom) {
                            Color.clear
                            bottomView()
                                .tint(.primary)
                                .offset(y: isNavigating ? uiSteadySafeAreaInsets.bottom : 0.0)
                        }
                        .frame(height: 121.0)
                    }
                    
                    VStack {
                        Spacer()
                        focusButton()
                            .padding(.bottom, 280.0 + geometry.safeAreaInsets.bottom - uiSteadySafeAreaInsets.bottom)
                    }
                    
                    zoomControl(geometry: geometry)
                }
                .padding(SceneViewConst.uiPadding)
                .padding(uiSteadySafeAreaInsets)
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
        .onChange(of: uiSafeAreaInsets) { newValue in
            if !isNavigating {
                uiSteadySafeAreaInsets = newValue
            }
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
                Button {
                    if let state = model.focusState {
                        switch state {
                        case .unfocused:
                            model.focusState = .focused
                        case .focused:
                            model.focusState = .following
                        case .following:
                            model.focusState = .focused
                        }
                    }
                } label: {
                    Group {
                        if let state = model.focusState {
                            switch state {
                            case .unfocused:
                                Image(systemName: "camera.metering.center.weighted.average")
                            case .focused:
                                Image(systemName: "camera.metering.partial")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.primary, .secondary)
                            case .following:
                                Image(systemName: "camera.metering.spot")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.secondary, .primary)
                            }
                        } else {
                            Image(systemName: "camera.metering.center.weighted.average")
                        }
                    }
                    .imageScale(.large)
                    .frame(width: SceneViewConst.uiButtonSize, height: SceneViewConst.uiButtonSize, alignment: .center)
                }
                .background(SceneViewConst.uiBgrMaterial)
                .tint(.primary)
                .cornerRadius(15.0)
                .shadow(radius: 1.0)
                .disabled(model.focusState == nil)
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
