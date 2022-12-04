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
    
    let inspectToolViewModel: InspectToolViewModel
    let moveToolViewModel: MoveToolViewModel
    let orientToolViewModel: OrientToolViewModel
    let scaleToolViewModel: ScaleToolViewModel
    let shadeToolViewModel: ShadeToolViewModel
    let animatePositionToolViewModel: AnimatePositionToolViewModel
    let animateShadeToolViewModel: AnimateShadeToolViewModel
    
    lazy var toolViewModels: [ToolViewModel] = [
        inspectToolViewModel,
        moveToolViewModel,
        orientToolViewModel,
        scaleToolViewModel,
        shadeToolViewModel,
        animatePositionToolViewModel,
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
    let objectPropertyEditingParams = ObjectPropertyEditingParams()
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        
        self.inspectToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.moveToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.orientToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.scaleToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.shadeToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animatePositionToolViewModel = .init(sceneViewModel: sceneViewModel)
        self.animateShadeToolViewModel = .init(sceneViewModel: sceneViewModel)
        
        self.activeToolViewModel = inspectToolViewModel
        
        objectFactory = ObjectFactory(scene: sceneViewModel.scene)
    }
    
    func createObject(meshId: SPTMeshId) {
        let scale: Float = 5.0
        var position = SPTPosition.get(object: sceneViewModel.viewCameraObject).spherical.origin
        position.y += scale
        let object = objectFactory.makeMesh(meshId: meshId, position: position, scale: scale)
        sceneViewModel.selectedObject = object
        sceneViewModel.focusedObject = object
    }
    
    func duplicateObject(_ original: SPTObject) {
        let duplicate = objectFactory.duplicateObject(original)
        for toolVM in toolViewModels {
            toolVM.onObjectDuplicate(original: original, duplicate: duplicate)
        }
        objectPropertyEditingParams.onObjectDuplicate(original: original, duplicate: duplicate)
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
        objectPropertyEditingParams.onObjectDestroy(object)
        SPTSceneProxy.destroyObject(object)
    }
    
}


struct RootView: View {
    
    @StateObject private var model: RootViewModel
    @StateObject private var sceneViewModel: SceneViewModel
    @StateObject private var actionBarModel: ActionBarModel
    @StateObject private var userInteractionState: UserInteractionState
    
    @State private var showsAnimatorsView = false
    @State private var showsNewObjectView = false
    @State private var showsSelectedObjectInspector = false
    @State private var playableScene: SPTPlayableSceneProxy?

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
            SceneView(model: sceneViewModel, edgeInsets: .init(top: 0.0, leading: 0.0, bottom: -Self.navigationEmptyVerticalAreaHeight, trailing: 0.0))
            .renderingPaused(showsAnimatorsView || showsNewObjectView || showsSelectedObjectInspector || playableScene != nil)
            .environmentObject(userInteractionState)
            .overlay(alignment: .bottomTrailing) {
                ActionBar(model: actionBarModel)
                    .background(Material.thin, ignoresSafeAreaEdges: [])
                    .cornerRadius(10.0)
                    .padding(.trailing, 16.0)
                    .shadow(radius: 1.0)
                    .visible(userInteractionState.isIdle)
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 0.0) {
                    topbar()
                    Divider()
                    editorsView()
                }
                .background(Material.bar)
                .compositingGroup()
                .shadow(radius: 0.5)
                .visible(userInteractionState.isIdle)
            }
            .safeAreaInset(edge: .bottom, spacing: Self.navigationEmptyVerticalAreaHeight) {
                VStack(spacing: 8.0) {
                    ZStack {
                        Color.clear
                        activeToolView()
                            .padding(.horizontal, 8.0)
                            .transition(.identity)
                            .frame(height: Self.toolControlViewsAreaHeight, alignment: .bottom)
                            .environmentObject(model.objectPropertyEditingParams)
                            .environmentObject(userInteractionState)
                    }
                    .frame(height: Self.toolControlViewsAreaHeight)
                    
                    ToolSelector(activeToolViewModel: $model.activeToolViewModel, toolViewModels: model.toolViewModels)
                        .contentHorizontalPadding(32.0)
                        .padding(.vertical, 4.0)
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
            AnimatorsView()
        }
        .sheet(isPresented: $showsNewObjectView) {
            NewObjectView() { meshId in
                model.createObject(meshId: meshId)
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
                } label: {
                    Image(systemName: "square.stack.3d.down.right")
                        .imageScale(.large)
                }
                .hidden()
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
                Text("Generative")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .frame(height: 44.0)
        .padding(.horizontal)
    }
    
    func editorsView() -> some View {
        HStack(spacing: 0.0) {
            Button {
                showsSelectedObjectInspector = true
            } label: {
                Image(systemName: "list.bullet")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .disabled(!sceneViewModel.isObjectSelected)
            Divider()
                .padding(.vertical, 4.0)
            Button {
                showsAnimatorsView = true
            } label: {
                Image(systemName: "bolt")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .tint(.primary)
        .frame(height: 33.0)
    }
    
    func activeToolView() -> some View {
        Group {
            switch model.activeToolViewModel.tool {
            case .inspect:
                EmptyView()
            case .move:
                MoveToolView(model: model.moveToolViewModel)
            case .orient:
                OrientToolView(model: model.orientToolViewModel)
            case .scale:
                ScaleToolView(model: model.scaleToolViewModel)
            case .shade:
                ShadeToolView(model: model.shadeToolViewModel)
            case .animatePosition:
                AnimatePositionToolView(model: model.animatePositionToolViewModel)
            case .animateOrientation:
                EmptyView()
            case .animateScale:
                EmptyView()
            case .animateShade:
                AnimateShadeToolView(model: model.animateShadeToolViewModel)
            }
        }
    }
    
    static let navigationEmptyVerticalAreaHeight: CGFloat = 80.0
    static let toolControlViewsAreaHeight: CGFloat = 121.0
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
