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
    
    let inspectToolViewModel: InspectToolViewModel
    let orientToolViewModel: OrientToolViewModel
    let scaleToolViewModel: ScaleToolViewModel
    let shadeToolViewModel: ShadeToolViewModel
    let animatePositionToolViewModel: AnimatePositionToolViewModel
    let animateOrientationToolViewModel: AnimateOrientationToolViewModel
    let animateScaleToolViewModel: AnimateScaleToolViewModel
    let animateShadeToolViewModel: AnimateShadeToolViewModel
    
    lazy var toolViewModels: [ToolViewModel] = [
        inspectToolViewModel,
        orientToolViewModel,
        scaleToolViewModel,
        shadeToolViewModel,
        animatePositionToolViewModel,
        animateOrientationToolViewModel,
        animateScaleToolViewModel,
        animateShadeToolViewModel
    ]
    
    @Published var activeToolViewModel: ToolViewModel {
        willSet {
            activeToolViewModel.onInactive()
        }
        didSet {
            activeToolViewModel.onActive()
        }
    }
    
    let objectFactory: ObjectFactory
    let objectEditingParams = ObjectEditingParams()
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        self.animatorsViewModel = .init()
        
        self.inspectToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.orientToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.scaleToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.shadeToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animatePositionToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateOrientationToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateScaleToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateShadeToolViewModel = .init(sceneViewModel: sceneViewModel)
        
        self.activeToolViewModel = inspectToolViewModel
        
        objectFactory = ObjectFactory(scene: sceneViewModel.scene)
        
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
        let object = objectFactory.makeMesh(meshId: meshId, lookCategories: [.renderable, .renderableModel], position: position, scale: scale)
        sceneViewModel.selectedObject = object
        sceneViewModel.focusedObject = object
    }
    
    func duplicateObject(_ original: SPTObject) {
        let duplicate = objectFactory.duplicateObject(original)
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
        objectEditingParams.onObjectDestroy(object)
        
        SPTSceneProxy.destroyObjectDeferred(object)
    }
    
}


struct RootView: View {
    
    @StateObject private var model: RootViewModel
    @StateObject private var sceneViewModel: SceneViewModel
    @StateObject private var moveToolModel = MoveToolModel()
    
    @StateObject private var actionBarModel: ActionBarModel
    @StateObject private var userInteractionState: UserInteractionState
    
    @State private var activeTool = Tool.inspect
    @State private var showsAnimatorsView = false
    @State private var showsNewObjectView = false
    @State private var showsSelectedObjectInspector = false
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
            .renderingPaused(showsAnimatorsView || showsNewObjectView || showsSelectedObjectInspector || playableScene != nil)
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
                VStack(spacing: 0.0) {
                    ZStack(alignment: .bottom) {
                        Color.clear
                        activeToolView()
                            .transition(.identity)
                            .environmentObject(model.objectEditingParams)
                            .environmentObject(userInteractionState)
                    }
                    .frame(height: Self.toolControlViewsAreaHeight)
                                        
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
        .sheet(isPresented: $showsSelectedObjectInspector) {
            MeshObjectInspector(model: .init(object: sceneViewModel.selectedObject!, rootViewModel: model))
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
        .onAppear {
            model.activeToolViewModel.onActive()
        }
        .onDisappear {
            model.activeToolViewModel.onInactive()
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
                OrientToolView(model: model.orientToolViewModel)
            case .scale:
                ScaleToolView(model: model.scaleToolViewModel)
            case .shade:
                ShadeToolView(model: model.shadeToolViewModel)
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
    }
    
    func activeToolBarView() -> some View {
        Group {
            switch activeTool {
            case .inspect:
                EmptyView()
            case .move:
                MoveToolBarView(model: moveToolModel)
            case .orient:
                EmptyView()
            case .scale:
                EmptyView()
            case .shade:
                EmptyView()
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
    }
    
    static let sceneUIInsets = EdgeInsets(top: 0.0, leading: 0.0, bottom: 80.0, trailing: 16.0)
    static let toolControlViewsAreaHeight: CGFloat = 129.0
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
