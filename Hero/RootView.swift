//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI

struct UserInteractionFlags: OptionSet {
    let rawValue: UInt
    
    static let navigation    = UserInteractionFlags(rawValue: 1 << 0)
    static let editing       = UserInteractionFlags(rawValue: 1 << 1)
}

class UserInteractionState: ObservableObject {
    
    @Published private var interactionFlags: UserInteractionFlags = []
    
    var isNavigating: Bool {
        set {
            withAnimation(.userInteractionStateChangeAnimation) {
                if newValue {
                    interactionFlags.insert(.navigation)
                } else {
                    interactionFlags.remove(.navigation)
                }
            }
        }
        get {
            interactionFlags.contains(.navigation)
        }
    }
    
    var isEditing: Bool {
        set {
            withAnimation(.userInteractionStateChangeAnimation) {
                if newValue {
                    interactionFlags.insert(.editing)
                } else {
                    interactionFlags.remove(.editing)
                }
            }
        }
        get {
            interactionFlags.contains(.editing)
        }
    }
    
    var isIdle: Bool {
        interactionFlags.isEmpty
    }
    
}

class RootViewModel: ObservableObject {
    
    let sceneViewModel: SceneViewModel
    let animatorsViewModel: AnimatorsViewModel
    
    let sceneGraph: SceneGraph
    let objectEditingParams = ObjectEditingParams()
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        self.animatorsViewModel = .init()
        
        sceneGraph = SceneGraph(scene: sceneViewModel.scene)
        
        // Create default object
        createObject(meshId: MeshRegistry.standard.recordNamed("sphere")!.id, position: .init(x: 0.0, y: 5.0, z: 0.0), scale: 5.0)
        
        // Create default animators
        _ = animatorsViewModel.makePanAnimator()
        _ = animatorsViewModel.makeRandomAnimator()
        _ = animatorsViewModel.makeOscillatorAnimator()
        _ = animatorsViewModel.makeValueNoise()
        _ = animatorsViewModel.makePerlinNoise()
        
    }
    
    func createObject(meshId: SPTMeshId, position: simd_float3, scale: Float) {
        let object = sceneGraph.makeMesh(meshId: meshId, lookCategories: [.renderable, .renderableModel], position: position, scale: scale)
        sceneViewModel.selectedObject = object
        sceneViewModel.focusedObject = object
    }
    
}


struct RootView: View {
    
    @StateObject private var model: RootViewModel
    @StateObject private var sceneViewModel: SceneViewModel
    @StateObject private var moveToolModel = BasicToolModel()
    @StateObject private var orientToolModel = BasicToolModel()
    @StateObject private var scaleToolModel = BasicToolModel()
    @StateObject private var shadeToolModel = BasicToolModel()
    @StateObject private var animatePositionToolModel = BasicToolModel()
    @StateObject private var animateOrientationToolModel = BasicToolModel()
    @StateObject private var animateScaleToolModel = BasicToolModel()
    @StateObject private var animateShadeToolModel = BasicToolModel()
    
    @StateObject private var userInteractionState: UserInteractionState
    
    @State private var activeTool = Tool.move
    @State private var showsAnimatorsView = false
    @State private var showsNewObjectView = false
    @State private var playableScene: SPTPlayableSceneProxy?
    @State private var showsBuildMetadata = false

    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let sceneVM = SceneViewModel()
        _sceneViewModel = .init(wrappedValue: sceneVM)
        _model = .init(wrappedValue: .init(sceneViewModel: sceneVM))
        _userInteractionState = .init(wrappedValue: .init())
    }
    
    var body: some View {
        SceneView(model: sceneViewModel, uiEdgeInsets: Self.sceneUIInsets)
            .lookCategories([.renderableModel, .guide])
            .renderingPaused(showsAnimatorsView || showsNewObjectView || playableScene != nil)
            .environmentObject(userInteractionState)
            .overlay(alignment: .bottomTrailing) {
                ActionBar(showsNewObjectView: $showsNewObjectView)
                    .padding(Self.sceneUIInsets)
                    .visible(userInteractionState.isIdle && activeTool.purpose == .build)
                    .environmentObject(sceneViewModel)
                    .environmentObject(model.sceneGraph)
                    .environmentObject(model.objectEditingParams)
            }
            .safeAreaInset(edge: .top, spacing: 0.0) {
                topbar()
                    .background(Material.bar)
                    .compositingGroup()
                    .shadow(radius: 0.5)
                    .visible(userInteractionState.isIdle)
            }
            .safeAreaInset(edge: .bottom, spacing: 0.0) {
                VStack(spacing: 8.0) {
                    ZStack(alignment: .bottom) {
                        Color.clear
                        activeToolView()
                            .transition(.identity)
                            .padding(.horizontal, 8.0)
                            .background(content: {
                                Color.clear
                                    .contentShape(Rectangle())
                            })
                    }
                    .frame(height: Self.toolControlViewsAreaHeight, alignment: .bottom)
                    .zIndex(1)
                                        
                    HStack {
                        toolSelector()
                        Color.clear
                            .frame(maxHeight: 44.0)
                            .overlay {
                                activeToolBarView()
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 8.0)
                    .background(Material.bar)
                    .compositingGroup()
                    .shadow(radius: 0.5)
                    
                }
                .visible(!userInteractionState.isNavigating)
            }
            .statusBar(hidden: !userInteractionState.isIdle)
            .persistentSystemOverlays(userInteractionState.isIdle ? .automatic : .hidden)
            .sheet(isPresented: $showsAnimatorsView) {
                AnimatorsView(model: model.animatorsViewModel)
            }
            .sheet(isPresented: $showsNewObjectView) {
                NewObjectView() { meshId in
                    model.createObject(meshId: meshId, position: sceneViewModel.viewCamera.focusPoint, scale: 5.0)
                }
            }
            .fullScreenCover(item: $playableScene, content: { scene in
                PlayView(model: PlayViewModel(scene: scene, viewCameraEntity: scene.params.viewCameraEntity))
            })
            .onChange(of: scenePhase) { [scenePhase] newScenePhase in
                // This should be part of 'PlayView' however for some reason
                // scene phase notifications work on the root view of the app
                if scenePhase == .active && newScenePhase == .inactive {
                    playableScene = nil
                }
            }
    }
    
    func topbar() -> some View {
        ZStack {
            HStack {
                Button {
                    showsAnimatorsView = true
                } label: {
                    Image(systemName: "bolt")
                        .imageScale(.large)
                }
                Spacer()
                Button {
                    playableScene = SPTPlayableSceneProxy(scene: sceneViewModel.scene, viewCameraEntity: sceneViewModel.viewCamera.sptObject.entity)
                } label: {
                    Image(systemName: "play")
                        .imageScale(.large)
                }
            }
            HStack {
                Spacer()
                if showsBuildMetadata {
                    Text("v\(Bundle.main.releaseVersionString)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    VStack {
                        Text("Generative")
                            .font(sceneViewModel.isObjectSelected ? .caption2 : .headline)
                            .foregroundColor(.primary)
                        if let selectedMetadata = sceneViewModel.selectedObjectMetadata {
                            Text(selectedMetadata.name)
                                .font(.subheadline)
                                .foregroundColor(.primarySelectionColor)
                                .transition(AnyTransition.opacity.combined(with: .scale))
                        }
                    }
                }
                Spacer()
            }
            .onTapGesture {
                showsBuildMetadata.toggle()
            }
        }
        .frame(height: 44.0)
        .padding(.horizontal)
    }
    
    fileprivate func toolSelector() -> some View {
        Menu {
            ForEach(Tool.allCases) { tool in
                Button {
                    self.activeTool = tool
                } label: {
                    HStack {
                        Text(tool.title)
                        Spacer()
                        if tool == activeTool {
                            Image(systemName: "checkmark.circle")
                                .imageScale(.small)
                        }
                    }
                }
            }
        } label: {
            Image(activeTool.iconName)
                .imageScale(.large)
        }
        .buttonStyle(.borderedProminent)
        .shadow(radius: 1.0)
    }
    
    func activeToolView() -> some View {
        Group {
            switch activeTool {
            case .move:
                MoveToolView(model: moveToolModel)
            case .orient:
                OrientToolView(model: orientToolModel)
            case .scale:
                ScaleToolView(model: scaleToolModel)
            case .shade:
                ShadeToolView(model: shadeToolModel)
            case .animatePosition:
                AnimatePositionToolView(model: animatePositionToolModel)
            case .animateOrientation:
                AnimateOrientationToolView(model: animateOrientationToolModel)
            case .animateScale:
                AnimateScaleToolView(model: animateScaleToolModel)
            case .animateShade:
                AnimateShadeToolView(model: animateShadeToolModel)
            }
        }
        .environmentObject(sceneViewModel)
        .environmentObject(model.objectEditingParams)
        .environmentObject(userInteractionState)
    }
    
    func activeToolBarView() -> some View {
        Group {
            switch activeTool {
            case .move:
                BasicToolBarView(tool: .move, model: moveToolModel)
            case .orient:
                BasicToolBarView(tool: .orient, model: orientToolModel)
            case .scale:
                BasicToolBarView(tool: .scale, model: scaleToolModel)
            case .shade:
                BasicToolBarView(tool: .shade, model: shadeToolModel)
            case .animatePosition:
                BasicToolBarView(tool: .animatePosition, model: animatePositionToolModel)
            case .animateOrientation:
                BasicToolBarView(tool: .animateOrientation, model: animateOrientationToolModel)
            case .animateScale:
                BasicToolBarView(tool: .animateScale, model: animateScaleToolModel)
            case .animateShade:
                BasicToolBarView(tool: .animateShade, model: animateShadeToolModel)
            }
        }
        .environmentObject(sceneViewModel)
        .environmentObject(model.objectEditingParams)
    }
    
    static let sceneUIInsets = EdgeInsets(top: 0.0, leading: 0.0, bottom: 80.0, trailing: 16.0)
    static let toolControlViewsAreaHeight: CGFloat = 129.0
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
