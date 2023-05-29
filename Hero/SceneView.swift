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
    
    @ObservedObject var scene: MainScene
    @State private var viewportSize = CGSize.zero
    let uiEdgeInsets: EdgeInsets
    
    private(set) var isRenderingPaused = false
    private(set) var lookCategories = LookCategories.all
    private(set) var isSelectionEnabled = true
    @GestureState private var isOrbitDragGestureActive = false
    @GestureState private var isZoomDragGestureActive = false
    @GestureState private var isPanDragGestureActive = false
    @State private var prevDragValue: DragGesture.Value?
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    init(scene: MainScene, uiEdgeInsets: EdgeInsets = EdgeInsets()) {
        self.scene = scene
        self.uiEdgeInsets = uiEdgeInsets
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
                        SPTView(scene: scene.sptScene, clearColor: clearColor, viewCameraEntity: scene.viewCamera.sptObject.entity)
                            .renderingPaused(isRenderingPaused)
                            .lookCategories(lookCategories.rawValue)
                        
                        // Adding 'allowsHitTesting' to 'SPTView' will cause its underlying view controller's 'viewWillAppear' to be called on each gesture start, hence creating a separate view on top
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(orbitDragGesture)
                            .onTapGesture { location in
                                guard isSelectionEnabled else { return }
                                withAnimation {
                                    scene.selectedObject = scene.pickObjectAt(location, viewportSize: viewportSize)
                                }
                            }
                            .allowsHitTesting(!userInteractionState.isNavigating)
                    }
                    .modifier(SizeModifier())
                    // Adjust SPTView size so that its center (hence where the camera points) matches with safe area center
                    .padding(sptViewPadding(safeArea: geometry.frame(in: .global), fullArea: sptViewGeometry.frame(in: .global)))
                }
                .ignoresSafeArea()
                
                controlsView
            }
        }
        .onChange(of: isOrbitDragGestureActive) { newValue in
            userInteractionState.isNavigating = newValue
            if !newValue {
                prevDragValue = nil
            }
        }
        .onChange(of: isZoomDragGestureActive) { newValue in
            userInteractionState.isNavigating = newValue
            if !newValue {
                prevDragValue = nil
            }
        }
        .onChange(of: isPanDragGestureActive) { newValue in
            userInteractionState.isNavigating = newValue
            if newValue {
                scene.isFocusEnabled = false
            } else {
                prevDragValue = nil
            }
        }
        .onChange(of: colorScheme) { _ in
            clearColor = UIColor.sceneBgrColor.mtlClearColor
        }
        .onPreferenceChange(SizePreferenceKey.self) { size in
            viewportSize = size
        }
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
    
    var controlsView: some View {
        VStack(spacing: 0.0) {
            HStack(spacing: 0.0) {
                VStack {
                    Spacer()
                    Button {
                        scene.isFocusEnabled = false
                        scene.viewCamera.reset()
                    } label: {
                        Image(systemName: "arrow.rectanglepath")
                            .imageScale(.medium)
                            .tint(.primary)
                    }
                    .frame(width: SceneViewConst.uiButtonSize, height: SceneViewConst.uiButtonSize, alignment: .center)
                    .background(SceneViewConst.uiBgrMaterial, ignoresSafeAreaEdges: [])
                    .cornerRadius(12.0)
                    .shadow(radius: 1.0)
                    
                    SceneUIToggle(isOn: $scene.isFocusEnabled, offStateIconName: "camera.metering.center.weighted.average", onStateIconName: "camera.metering.spot")
                        .transition(.identity)
                }
                .padding(.leading, 8.0)
                Spacer()
                ZoomView()
                    .frame(width: 16.0, alignment: .trailing)
                    .contentShape(Rectangle())
                    .gesture(zoomDragGesture(viewportSize: viewportSize))
            }
            .visible(userInteractionState.isIdle)
            HStack {
                panAreaView(viewportSize: viewportSize)
                Spacer()
                panAreaView(viewportSize: viewportSize)
            }
            .frame(height: uiEdgeInsets.bottom)
        }
    }
    
    // MARK: Orbit
    var orbitDragGesture: some Gesture {
        DragGesture()
            .updating($isOrbitDragGestureActive, body: { _, state, _ in
                state = true
            })
            .onChanged { value in
                
                guard let prevDragValue = self.prevDragValue else {
                    self.prevDragValue = value
                    return
                }
                self.prevDragValue = value
                
                let deltaTranslation = value.translation.float2 - prevDragValue.translation.float2
                let deltaAngle = Float.pi * deltaTranslation / Self.orbitTranslationPerHalfRevolution
                
                scene.viewCamera.orbit(deltaAngle: deltaAngle)
                
            }
            .onEnded { value in
                // Deliberately ignoring last drag value to avoid orbit nudge
                prevDragValue = nil
            }
    }
    
    static let orbitTranslationPerHalfRevolution: Float = 300.0
    
    // MARK: Zoom
    func zoomDragGesture(viewportSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($isZoomDragGestureActive, body: { _, state, _ in
                state = true
            })
            .onChanged { value in
                
                guard let prevDragValue = self.prevDragValue else {
                    self.prevDragValue = value
                    return
                }
                self.prevDragValue = value
                
                let deltaYTranslation = Float(value.translation.height - prevDragValue.translation.height)
                
                scene.viewCamera.zoom(deltaY: Self.zoomFactor * deltaYTranslation, viewportSize: viewportSize)
                
            }
            .onEnded { value in
                // Deliberately ignoring last drag value to avoid zoom nudge
                prevDragValue = nil
            }
    }
    
    static let zoomFactor: Float = 3.0
    
    // MARK: Pan
    func panAreaView(viewportSize: CGSize) -> some View {
        Color.clear
            .frame(width: 44.0)
            .contentShape(Rectangle())
            .gesture(panDragGesture(viewportSize: viewportSize))
            .ignoresSafeArea(edges: .bottom)
    }
    
    func panDragGesture(viewportSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($isPanDragGestureActive, body: { _, state, _ in
                state = true
            })
            .onChanged { value in
                
                // Typically the first non-zero drag translation is big which results to aggresive jerk on the start, hence first non-zero translation is ignored
                guard let prevDragValue = self.prevDragValue else {
                    if value.translation == .zero {
                        return
                    }
                    self.prevDragValue = value
                    return
                }
                self.prevDragValue = value
                
                let deltaTranslation = value.translation.float2 - prevDragValue.translation.float2
                
                scene.viewCamera.pan(translation: deltaTranslation, viewportSize: viewportSize)
                
            }
            .onEnded { value in
                // Deliberately ignoring last drag value to avoid pan nudge
                prevDragValue = nil
            }
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
        
        @StateObject var scene = MainScene()
        
        var body: some View {
            SceneView(scene: scene)
                .environmentObject(UserInteractionState())
        }
    }
    
    static var previews: some View {
        SceneViewContainer()
    }
}
