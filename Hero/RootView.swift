//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI


enum Tool: Int, CaseIterable, Identifiable {
    
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
    
    @StateObject var sceneViewModel = SceneViewModel()
    @State private var isNavigating = false
    @State private var isToolActive = false
    @State private var tool = Tool.move
    @State private var showsAnimatorsView = false
    @State private var showsNewObjectView = false
    @State private var showsSelectedObjectInspector = false
    @State private var playableScene: SPTPlayableSceneProxy?

    @Environment(\.scenePhase) private var scenePhase
    
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
                isToolActive = true
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
            if isToolActive {
                switch tool {
                case .move:
                    MoveToolControlsView(model: .init(sceneViewModel: sceneViewModel))
                case .orient:
                    OrientToolControlsView(model: .init(sceneViewModel: sceneViewModel))
                case .scale:
                    ScaleToolControlsView(model: .init(sceneViewModel: sceneViewModel))
                case .shade:
                    EmptyView()
                case .animmove:
                    EmptyView()
                case .animorient:
                    EmptyView()
                case .animscale:
                    EmptyView()
                case .animshade:
                    EmptyView()
                }
            } else {
                if let selected = sceneViewModel.selectedObject {
                    objectActionView(selected)
                }
            }
        }
    }
    
    func bottombar() -> some View {
        ZStack {
            if isToolActive {
                activeToolOptionsView()
            } else {
                defaultActionsView()
            }
            HStack {
                Spacer()
                toolSelector()
                Spacer()
            }
        }
        .frame(height: 50.0)
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
                    isToolActive = true
                } label: {
                    HStack {
                        Text(tool.title)
                        Spacer()
                        Image(tool.iconName)
                    }
                }
            }
        } label: {
            
            VStack(spacing: 2.0) {
                Image(tool.iconName)
                    .imageScale(.large)
                    .foregroundColor(isToolActive ? .systemBackground : .primary)
                Image(systemName: "ellipsis")
                    .imageScale(.small)
                    .foregroundColor(isToolActive ? .secondarySystemBackground : .secondary)
                    .fontWeight(.light)
            }
            .frame(width: 48.0, height: 42.0)
            .background {
                Color.primary.opacity(isToolActive ? 0.8 : 0.0)
                    .cornerRadius(5.0)
                    .shadow(radius: 1.0)
            }
            .shadow(radius: isToolActive ? 0.0 : 1.0)
            
        } primaryAction: {
            isToolActive.toggle()
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
        }
    }
    
    func activeToolOptionsView() -> some View {
        Group {
            switch tool {
            case .move:
                EmptyView()
            case .orient:
                EmptyView()
            case .scale:
                EmptyView()
            case .shade:
                EmptyView()
            case .animmove:
                EmptyView()
            case .animorient:
                EmptyView()
            case .animscale:
                EmptyView()
            case .animshade:
                EmptyView()
            }
        }
    }
    
    func objectActionView(_ object: SPTObject) -> some View {
        HStack(spacing: 4.0) {
            objectActionButton(iconName: "slider.horizontal.3") {
                showsSelectedObjectInspector = true
            }
            objectActionButton(iconName: "plus.square.on.square") {
                sceneViewModel.duplicateObject(object)
                tool = .move
                isToolActive = true
                
            }
            objectActionButton(iconName: "trash") {
                sceneViewModel.destroySelected()
            }
        }
        .frame(height: 44.0)
        .padding(4.0)
        .background(SceneViewConst.uiBgrMaterial)
        .cornerRadius(9.0)
        .shadow(radius: 1.0)
        .selectedObjectUI(cornerRadius: 9.0)
        .tint(.primary)
    }
    
    func objectActionButton(iconName: String, onPress: @escaping () -> Void) -> some View {
        Button(action: onPress) {
            ZStack {
                Color.systemFill
                Image(systemName: iconName)
                    .imageScale(.large)
            }
            .cornerRadius(5.0)
            .containerShape(Rectangle())
        }
    }
    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
