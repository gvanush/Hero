//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.21.
//

import SwiftUI


struct SceneViewConst {
    static let uiBgrMaterial = Material.thin
    static let uiPadding = 16.0
    static let uiButtonSize = 44.0
}

struct SceneView: View {
    
    @ObservedObject var model: SceneViewModel
    @State private var viewportSize = CGSize.zero
    let edgeInsets: EdgeInsets
    
    private(set) var isRenderingPaused = false
    private(set) var lookCategories = LookCategories.all
    private(set) var isSelectionEnabled = true
    @GestureState private var isOrbitDragGestureActive = false
    @GestureState private var isZoomDragGestureActive = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    init(model: SceneViewModel, edgeInsets: EdgeInsets = EdgeInsets()) {
        self.model = model
        self.edgeInsets = edgeInsets
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
                GeometryReader { sptViewGeometry in
                    Group {
                        SPTView(scene: model.scene, clearColor: clearColor, viewCameraEntity: model.viewCameraObject.entity)
                            .renderingPaused(isRenderingPaused)
                            .lookCategories(lookCategories.rawValue)
                        
                        // NOTE: Adding 'allowsHitTesting' to 'SPTView' will cause its underlying
                        // view controller's 'viewWillAppear' to be called on each gesture start,
                        // hence creating a separate view on top
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(orbitDragGesture)
                            .onTapGesture { location in
                                guard isSelectionEnabled else { return }
                                withAnimation {
                                    model.selectedObject = model.pickObjectAt(location, viewportSize: viewportSize)
                                }
                            }
                            .allowsHitTesting(!userInteractionState.isNavigating)
                    }
                    .modifier(SizeModifier())
                    // Adjust SPTView size so that its center (hence where the camera points) matches with safe area center
                    .padding(sptViewPadding(safeArea: geometry.frame(in: .global), fullArea: sptViewGeometry.frame(in: .global)))
                }
                .ignoresSafeArea()
                
                Group {
                    VStack {
                        objectInfoView()
                        Spacer()
                    }
                    .visible(userInteractionState.isIdle)
                    
                    HStack(spacing: 0.0) {
                        VStack {
                            Spacer()
                            focusToggle()
                        }
                        .padding(.leading, 8.0)
                        .visible(userInteractionState.isIdle)
                        Spacer()
                        ZoomView()
                            .frame(width: 16.0, alignment: .trailing)
                            .contentShape(Rectangle())
                            .gesture(zoomDragGesture(viewportSize: viewportSize))
                            .padding(.bottom, edgeInsets.bottom)
                            .visible(!userInteractionState.isNavigating)
                    }
                }
            }
        }
        .onChange(of: isOrbitDragGestureActive) { newValue in
            userInteractionState.isNavigating = newValue
            if !newValue {
                model.cancelOrbit()
            }
        }
        .onChange(of: isZoomDragGestureActive) { newValue in
            userInteractionState.isNavigating = newValue
            if !newValue {
                model.cancelZoom()
            }
        }
        .onChange(of: colorScheme) { _ in
            clearColor = UIColor.sceneBgrColor.mtlClearColor
        }
        .onPreferenceChange(SizePreferenceKey.self) { size in
            viewportSize = size
        }
    }
    
    func focusToggle() -> some View {
        SceneUIToggle(isOn: $model.isFocusEnabled, offStateIconName: "camera.metering.center.weighted.average", onStateIconName: "camera.metering.partial")
        .transition(.identity)
        .id(model.selectedObject)
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
    
    func objectInfoView() -> some View {
        Group {
            if let name = model.selectedObjectMetadata?.name {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.primarySelectionColor)
                    .frame(height: 30)
                    .padding(.horizontal, 8.0)
                    .background(SceneViewConst.uiBgrMaterial)
                    .cornerRadius(9.0)
                    .shadow(radius: 1.0)
            }
        }
        .transition(.identity)
        .id(model.selectedObject)
    }
    
    func sptViewPadding(safeArea: CGRect, fullArea: CGRect) -> EdgeInsets {
        var insets = EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
        
        let verticalInset = 2.0 * (safeArea.center.y - fullArea.center.y)
        if verticalInset < 0.0 {
            insets.top = verticalInset
        } else {
            insets.bottom = verticalInset
        }
        
        let horizontalInset = -2.0 * (safeArea.center.x - fullArea.center.x)
        if horizontalInset < 0.0 {
            insets.leading = horizontalInset
        } else {
            insets.trailing = horizontalInset
        }
        
        return insets
    }
    
}

fileprivate struct ZoomView: View {
    
    var body: some View {
        VLine()
            .stroke(style: Self.lineStrokeStyle)
            .background(SceneViewConst.uiBgrMaterial)
            .frame(width: Self.width)
            .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black.opacity(0.0)], startPoint: .bottom, endPoint: .top))

    }
    
    static let width = 8.0
    static let lineStrokeStyle = StrokeStyle(lineWidth: Self.width, dash: [1, 4])
}

struct SceneView_Previews: PreviewProvider {
    
    struct SceneViewContainer: View {
        
        @StateObject var model = SceneViewModel()
        
        var body: some View {
            SceneView(model: model)
                .environmentObject(UserInteractionState())
        }
    }
    
    static var previews: some View {
        SceneViewContainer()
    }
}
