//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI


class RootViewModel: ObservableObject {
    
    let sceneViewModel: SceneViewModel
    
    let inspectToolViewModel: InspectToolViewModel
    let moveToolViewModel: MoveToolViewModel
    let orientToolViewModel: OrientToolViewModel
    let scaleToolViewModel: ScaleToolViewModel
    let shadeToolViewModel: ShadeToolViewModel
    let animatePositionToolView: AnimatePositionToolViewModel
    lazy var toolViewModels: [ToolViewModel] = [
        inspectToolViewModel,
        moveToolViewModel,
        orientToolViewModel,
        scaleToolViewModel,
        shadeToolViewModel,
        animatePositionToolView,
    ]
    
    @Published var activeToolViewModel: ToolViewModel
    
    let objectFactory: ObjectFactory
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        
        self.inspectToolViewModel = InspectToolViewModel(sceneViewModel: sceneViewModel)
        self.moveToolViewModel = MoveToolViewModel(sceneViewModel: sceneViewModel)
        self.orientToolViewModel = OrientToolViewModel(sceneViewModel: sceneViewModel)
        self.scaleToolViewModel = ScaleToolViewModel(sceneViewModel: sceneViewModel)
        self.shadeToolViewModel = ShadeToolViewModel(sceneViewModel: sceneViewModel)
        self.animatePositionToolView = AnimatePositionToolViewModel(sceneViewModel: sceneViewModel)
        
        self.activeToolViewModel = inspectToolViewModel
        
        objectFactory = ObjectFactory(scene: sceneViewModel.scene)
    }
    
    func createObject(meshId: SPTMeshId) {
        let object = objectFactory.makeMesh(meshId: meshId, position: SPTPosition.get(object: sceneViewModel.viewCameraObject).spherical.center)
        sceneViewModel.selectedObject = object
        sceneViewModel.focusedObject = object
    }
    
    func duplicateObject(_ original: SPTObject) {
        let duplicate = objectFactory.duplicateObject(original)
        for toolVM in toolViewModels {
            toolVM.onObjectDuplicate(original: original, duplicate: duplicate)
        }
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
        SPTSceneProxy.destroyObject(object)
    }
    
}


struct RootView: View {
    
    @StateObject private var model: RootViewModel
    @StateObject private var sceneViewModel: SceneViewModel
    @StateObject private var actionBarModel: ActionBarModel
    
    @State private var isNavigating = false
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
    }
    
    var body: some View {
        ActionBarItemReader(model: actionBarModel) {
            SceneView(model: sceneViewModel,
                      isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation), edgeInsets: .init(top: 0.0, leading: 0.0, bottom: -Self.navigationEmptyVerticalAreaHeight, trailing: 0.0))
            .renderingPaused(showsAnimatorsView || showsNewObjectView || showsSelectedObjectInspector || playableScene != nil)
            .overlay(alignment: .bottomTrailing) {
                ActionBar(model: actionBarModel)
                    .background(Material.thin, ignoresSafeAreaEdges: [])
                    .cornerRadius(10.0)
                    .padding(.trailing, 16.0)
                    .shadow(radius: 1.0)
                    .visible(!isNavigating)
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
                .visible(!isNavigating)
            }
            .safeAreaInset(edge: .bottom, spacing: Self.navigationEmptyVerticalAreaHeight) {
                VStack(spacing: 8.0) {
                    ZStack {
                        Color.clear
                        activeToolView()
                            .padding(.horizontal, 8.0)
                            .transition(.identity)
                            .frame(height: Self.toolControlViewsAreaHeight, alignment: .bottom)
                    }
                    .frame(height: Self.toolControlViewsAreaHeight)
                    
                    ToolSelector(activeToolViewModel: $model.activeToolViewModel, toolViewModels: model.toolViewModels)
                        .contentHorizontalPadding(32.0)
                        .padding(.vertical, 4.0)
                        .background(Material.bar)
                        .compositingGroup()
                        .shadow(radius: 0.5)
                }
                .visible(!isNavigating)
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
        .statusBar(hidden: isNavigating)
        .persistentSystemOverlays(isNavigating ? .hidden : .automatic)
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
                Image(systemName: "slider.horizontal.3")
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
                AnimatePositionToolView(model: model.animatePositionToolView)
            case .animateOrientation:
                EmptyView()
            case .animateScale:
                EmptyView()
            case .animateShade:
                EmptyView()
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
