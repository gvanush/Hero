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
    let animatePositionToolView: AnimatePositionToolViewModel
    lazy var toolViewModels: [ToolViewModel] = [
        inspectToolViewModel,
        moveToolViewModel,
        orientToolViewModel,
        scaleToolViewModel,
        animatePositionToolView,
    ]
    
    @Published var activeToolViewModel: ToolViewModel
    @Published var showsNewObjectView = false
    @Published var showsSelectedObjectInspector = false
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        
        self.inspectToolViewModel = InspectToolViewModel(sceneViewModel: sceneViewModel)
        self.moveToolViewModel = MoveToolViewModel(sceneViewModel: sceneViewModel)
        self.orientToolViewModel = OrientToolViewModel(sceneViewModel: sceneViewModel)
        self.scaleToolViewModel = ScaleToolViewModel(sceneViewModel: sceneViewModel)
        self.animatePositionToolView = AnimatePositionToolViewModel(sceneViewModel: sceneViewModel)
        
        self.activeToolViewModel = inspectToolViewModel
    }
    
    lazy var genericActions = [
        ActionItem(iconName: "plus", action: onNewObjectAction),
        ActionItem(iconName: "plus.square.on.square", disabled: objectActionsDisabled, action: onDuplicateAction),
        ActionItem(iconName: "slider.horizontal.3", disabled: objectActionsDisabled, action: onInspectObjectAction),
        ActionItem(iconName: "trash", disabled: objectActionsDisabled, action: onRemoveObjectAction)
    ]
    
    @Published var objectActions: [ActionItem]?
    
    func onNewObjectAction() {
        showsNewObjectView = true
    }
    
    func onDuplicateAction() {
        sceneViewModel.duplicateObject(sceneViewModel.selectedObject!)
    }
    
    func onInspectObjectAction() {
        showsSelectedObjectInspector = true
    }
    
    func onRemoveObjectAction() {
        sceneViewModel.destroySelected()
    }
    
    func objectActionsDisabled() -> Bool {
        !sceneViewModel.isObjectSelected
    }
    
}


struct RootView: View {
    
    @StateObject private var model: RootViewModel
    @StateObject private var sceneViewModel: SceneViewModel
    
    @State private var isNavigating = false
    @State private var showsAnimatorsView = false
    @State private var playableScene: SPTPlayableSceneProxy?

    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let sceneVM = SceneViewModel()
        _sceneViewModel = .init(wrappedValue: sceneVM)
        _model = .init(wrappedValue: .init(sceneViewModel: sceneVM))
    }
    
    var body: some View {
        ZStack {
            SceneView(model: sceneViewModel,
                      isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation), edgeInsets: .init(top: 0.0, leading: 0.0, bottom: -Self.navigationEmptyVerticalAreaHeight, trailing: 0.0))
            .overlay {
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        EmptyView()
                        ActionsView(primaryActions: $model.genericActions, secondaryActions: $model.objectActions)
                            .padding(3.0)
                            .background(Material.bar, ignoresSafeAreaEdges: [])
                            .cornerRadius(5.0, corners: [.topRight, .bottomRight])
                            .shadow(radius: 1.0)
                        Spacer()
                    }
                }
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
            
        }
        .statusBar(hidden: isNavigating)
        .persistentSystemOverlays(isNavigating ? .hidden : .automatic)
        .sheet(isPresented: $model.showsNewObjectView) {
            NewObjectView() { meshId in
                sceneViewModel.createNewObject(meshId: meshId)
            }
        }
        .sheet(isPresented: $showsAnimatorsView) {
            AnimatorsView()
        }
        .sheet(isPresented: $model.showsSelectedObjectInspector) {
            MeshObjectInspector(meshComponent: MeshObjectComponent(object: sceneViewModel.selectedObject!, sceneViewModel: sceneViewModel))
                .environmentObject(sceneViewModel)
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
                showsAnimatorsView = true
            } label: {
                Image(systemName: "bolt")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .contentShape(Rectangle())
            Divider()
                .padding(.vertical, 4.0)
            Button {
            } label: {
                Image(systemName: "list.bullet.indent")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .contentShape(Rectangle())
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
                EmptyView()
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
