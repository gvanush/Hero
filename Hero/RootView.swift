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
    
    let animatePositionToolViewModel: AnimatePositionToolViewModel
    let animateOrientationToolViewModel: AnimateOrientationToolViewModel
    let animateScaleToolViewModel: AnimateScaleToolViewModel
    let animateShadeToolViewModel: AnimateShadeToolViewModel
    
    lazy var toolViewModels: [ToolViewModel] = [
        animatePositionToolViewModel,
        animateOrientationToolViewModel,
        animateScaleToolViewModel,
        animateShadeToolViewModel
    ]
    
    let sceneGraph: SceneGraph
    let objectEditingParams = ObjectEditingParams()
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        self.animatorsViewModel = .init()
        
        self.animatePositionToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateOrientationToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateScaleToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateShadeToolViewModel = .init(sceneViewModel: sceneViewModel)
        
        sceneGraph = SceneGraph(scene: sceneViewModel.scene)
        
        // Create default object
        var defaultObjectPosition = SPTPosition.get(object: sceneViewModel.viewCameraObject).spherical.origin
        defaultObjectPosition.y += 5.0
        createObject(meshId: MeshRegistry.standard.recordNamed("sphere")!.id, position: defaultObjectPosition, scale: 5.0)
        
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
    
    func duplicateObject(_ original: SPTObject) {
        let duplicate = sceneGraph.duplicateObject(original)
        for toolVM in toolViewModels {
            toolVM.onObjectDuplicate(original: original, duplicate: duplicate)
        }
        objectEditingParams.onObjectDuplicate(original: original, duplicate: duplicate)
        sceneViewModel.selectedObject = duplicate
        sceneViewModel.focusedObject = duplicate
    }
    
    func destroyObject(_ object: SPTObject) {
        if object == sceneViewModel.selectedObject {
            sceneViewModel.selectedObject = nil
        }
        if object == sceneViewModel.focusedObject {
            sceneViewModel.focusedObject = nil
        }
        for toolVM in toolViewModels {
            toolVM.onObjectDestroy(object)
        }
        
        // Schedule object removal at the end of the run loop when
        // SwiftUI already processed all view lifecycle events
        let runLoopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, false, 0, { _, _ in
            self.objectEditingParams.onObjectDestroy(object)
            self.sceneGraph.destroyObject(object)
        })
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserver, .defaultMode)
     
    }
    
}


struct RootView: View {
    
    @StateObject private var model: RootViewModel
    @StateObject private var sceneViewModel: SceneViewModel
    @StateObject private var moveToolModel = BasicToolModel()
    @StateObject private var orientToolModel = BasicToolModel()
    @StateObject private var scaleToolModel = BasicToolModel()
    @StateObject private var shadeToolModel = BasicToolModel()
    
    @StateObject private var actionBarModel: ActionBarModel
    @StateObject private var userInteractionState: UserInteractionState
    
    @State private var activeTool = Tool.inspect
    @State private var showsAnimatorsView = false
    @State private var showsNewObjectView = false
    @State private var playableScene: SPTPlayableSceneProxy?
    @State private var showsBuildMetadata = false

    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let sceneVM = SceneViewModel()
        _sceneViewModel = .init(wrappedValue: sceneVM)
        _model = .init(wrappedValue: .init(sceneViewModel: sceneVM))
        _actionBarModel = .init(wrappedValue: .init())
        _userInteractionState = .init(wrappedValue: .init())
    }
    
    var body: some View {
        ActionBarItemReader(model: actionBarModel) {
            SceneView(model: sceneViewModel, uiEdgeInsets: Self.sceneUIInsets)
                .lookCategories([.renderableModel, .guide])
            .renderingPaused(showsAnimatorsView || showsNewObjectView || playableScene != nil)
            .environmentObject(userInteractionState)
            .overlay(alignment: .bottomTrailing) {
                ActionBar(model: actionBarModel)
                    .padding(Self.sceneUIInsets)
                    .visible(userInteractionState.isIdle)
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
                    }
                    .padding(.horizontal, 8.0)
                    .frame(height: Self.toolControlViewsAreaHeight)
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
                .background(content: {
                    // To block touches behind
                    Color.clear
                        .contentShape(Rectangle())
                })
                .visible(!userInteractionState.isNavigating)
            }
            .actionBarCommonSection {
                ActionBarButton(iconName: "plus") {
                    showsNewObjectView = true
                }
                
                ActionBarButton(iconName: "plus.square.on.square", disabled: !sceneViewModel.isObjectSelected) {
                    model.duplicateObject(sceneViewModel.selectedObject!)
                }
                
                ActionBarButton(iconName: "trash", disabled: !sceneViewModel.isObjectSelected) {
                    model.destroyObject(sceneViewModel.selectedObject!)
                }
            }
            .environmentObject(actionBarModel)
            
        }
        .statusBar(hidden: !userInteractionState.isIdle)
        .persistentSystemOverlays(userInteractionState.isIdle ? .automatic : .hidden)
        .sheet(isPresented: $showsAnimatorsView) {
            AnimatorsView(model: model.animatorsViewModel)
        }
        .sheet(isPresented: $showsNewObjectView) {
            NewObjectView() { meshId in
                model.createObject(meshId: meshId, position: SPTPosition.get(object: sceneViewModel.viewCameraObject).spherical.origin, scale: 5.0)
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
                    playableScene = SPTPlayableSceneProxy(scene: sceneViewModel.scene, viewCameraEntity: sceneViewModel.viewCameraObject.entity)
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
            case .inspect:
                EmptyView()
            case .move:
                MoveToolView(model: moveToolModel)
            case .orient:
                OrientToolView(model: orientToolModel)
            case .scale:
                ScaleToolView(model: scaleToolModel)
            case .shade:
                ShadeToolView(model: shadeToolModel)
            case .animatePosition:
                AnimatePositionToolView(model: model.animatePositionToolViewModel)
            case .animateOrientation:
                AnimateOrientationToolView(model: model.animateOrientationToolViewModel)
            case .animateScale:
                AnimateScaleToolView(model: model.animateScaleToolViewModel)
            case .animateShade:
                AnimateShadeToolView(model: model.animateShadeToolViewModel)
            }
        }
        .environmentObject(sceneViewModel)
        .environmentObject(model.objectEditingParams)
        .environmentObject(userInteractionState)
    }
    
    func activeToolBarView() -> some View {
        Group {
            switch activeTool {
            case .inspect:
                EmptyView()
            case .move:
                BasicToolBarView(tool: .move, model: moveToolModel)
            case .orient:
                BasicToolBarView(tool: .orient, model: orientToolModel)
            case .scale:
                BasicToolBarView(tool: .scale, model: scaleToolModel)
            case .shade:
                BasicToolBarView(tool: .shade, model: shadeToolModel)
            case .animatePosition:
                EmptyView()
            case .animateOrientation:
                EmptyView()
            case .animateScale:
                EmptyView()
            case .animateShade:
                EmptyView()
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
