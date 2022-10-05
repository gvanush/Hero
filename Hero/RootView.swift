//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI


enum Tool: Int, CaseIterable, Identifiable {
    
    case inspect
    case move
    case orient
    case scale
    case shade
    case animmove
    case animorient
    case animscale
    case animshade
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .inspect:
            return "Inspect"
        case .move:
            return "Move"
        case .orient:
            return "Orient"
        case .scale:
            return "Scale"
        case .shade:
            return "Shade"
        case .animmove:
            return "Animmove"
        case .animorient:
            return "Animorient"
        case .animscale:
            return "Animscale"
        case .animshade:
            return "Animashade"
        }
    }
    
    var iconName: String {
        switch self {
        case .inspect:
            return "inspect"
        case .move:
            return "move"
        case .orient:
            return "orient"
        case .scale:
            return "scale"
        case .shade:
            return "shade"
        case .animmove:
            return "animmove"
        case .animorient:
            return "animorient"
        case .animscale:
            return "animscale"
        case .animshade:
            return "animshade"
        }
    }
}


struct RootView: View {
    
    @StateObject private var sceneViewModel: SceneViewModel
    @StateObject private var animmoveToolViewModel: AnimmoveToolViewModel
    
    @State private var isNavigating = false
    @State private var tool = Tool.inspect
    @State private var showsAnimatorsView = false
    @State private var showsNewObjectView = false
    @State private var showsSelectedObjectInspector = false
    @State private var playableScene: SPTPlayableSceneProxy?

    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let sceneVM = SceneViewModel()
        _sceneViewModel = .init(wrappedValue: sceneVM)
        _animmoveToolViewModel = .init(wrappedValue: .init(sceneViewModel: sceneVM))
    }
    
    var body: some View {
        ZStack {
            SceneView(model: sceneViewModel,
                      uiSafeAreaInsets: .init(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0),
                      isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation))
            .ignoresSafeArea()
            
            VStack(spacing: 0.0) {
                VStack(spacing: 0.0) {
                    topbar()
                    Divider()
                    editorsView()
                }
                .background(Material.bar)
                .compositingGroup()
                .shadow(radius: 0.5)
                
                objectInfoView()
                    .padding(8.0)
                
                Spacer()
                
                controlsView()
                    .padding(8.0)
                bottombar()
            }
            .visible(!isNavigating)
        }
        .statusBar(hidden: isNavigating)
        .persistentSystemOverlays(isNavigating ? .hidden : .automatic)
        .sheet(isPresented: $showsNewObjectView) {
            NewObjectView() { meshId in
                sceneViewModel.createNewObject(meshId: meshId)
                tool = .move
            }
        }
        .sheet(isPresented: $showsAnimatorsView) {
            AnimatorsView()
        }
        .sheet(isPresented: $showsSelectedObjectInspector) {
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
    
    func objectInfoView() -> some View {
        Group {
            if let name = sceneViewModel.selectedObjectMetadata?.name {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.secondaryLabel)
                    .frame(height: 30)
                    .padding(.horizontal, 8.0)
                    .background(SceneViewConst.uiBgrMaterial)
                    .cornerRadius(9.0)
                    .selectedObjectUI(cornerRadius: 9.0)
            }
        }
    }
    
    func controlsView() -> some View {
        
        Group {
            switch tool {
            case .inspect:
                EmptyView()
            case .move:
                MoveToolControlsView(model: .init(sceneViewModel: sceneViewModel))
            case .orient:
                OrientToolControlsView(model: .init(sceneViewModel: sceneViewModel))
            case .scale:
                ScaleToolControlsView(model: .init(sceneViewModel: sceneViewModel))
            case .shade:
                EmptyView()
            case .animmove:
                AnimmoveToolControlsView(model: animmoveToolViewModel)
            case .animorient:
                EmptyView()
            case .animscale:
                EmptyView()
            case .animshade:
                EmptyView()
            }
        }
    }
    
    func bottombar() -> some View {
        VStack(spacing: 0.0) {
            activeToolOptionsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 44.0)
            HStack(spacing: 0.0) {
                HLine()
                    .stroke(lineWidth: 0.5)
                    .foregroundColor(.gray)
                toolSelector()
                HLine()
                    .stroke(lineWidth: 0.5)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4.0)
        }
        .frame(height: 82.0)
        .padding(.horizontal)
        .background(Material.bar)
        .compositingGroup()
        .shadow(radius: 0.5)
    }
    
    func toolSelector() -> some View {
        Menu {
            ForEach(Tool.allCases, id: \.id) { tool in
                Button {
                    self.tool = tool
                } label: {
                    HStack {
                        Text(tool.title)
                        Spacer()
                        Image(tool.iconName)
                    }
                }
            }
        } label: {
            Image(tool.iconName)
                .foregroundColor(.primary)
                .imageScale(.large)
                .frame(width: 48.0, height: 30.0)
        }
    }
    
    func defaultActionsView() -> some View {
        HStack {
            Button {
                showsNewObjectView = true
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }
            
            Spacer()
            
            Button {
                sceneViewModel.duplicateObject(sceneViewModel.selectedObject!)
                tool = .move
            } label: {
                Image(systemName: "plus.square.on.square")
                    .imageScale(.large)
            }
            .disabled(!sceneViewModel.isObjectSelected)
            
            Spacer()
            
            Button {
                showsSelectedObjectInspector = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.large)
            }
            .disabled(!sceneViewModel.isObjectSelected)
            .tint(Color.objectSelectionColor)
            
            Spacer()
            
            Button {
                sceneViewModel.destroySelected()
            } label: {
                Image(systemName: "trash")
                    .imageScale(.large)
            }
            .disabled(!sceneViewModel.isObjectSelected)
            .tint(Color.objectSelectionColor)
            
        }
    }
    
    func activeToolOptionsView() -> some View {
        Group {
            switch tool {
            case .inspect:
                defaultActionsView()
            case .move:
                defaultActionsView()
            case .orient:
                defaultActionsView()
            case .scale:
                defaultActionsView()
            case .shade:
                defaultActionsView()
            case .animmove:
                AnimmoveToolOptionsView(model: animmoveToolViewModel)
            case .animorient:
                EmptyView()
            case .animscale:
                EmptyView()
            case .animshade:
                EmptyView()
            }
        }
    }
    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
