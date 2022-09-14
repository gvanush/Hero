//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI

struct RootView: View {
    
    @StateObject var sceneViewModel = SceneViewModel()
    @State private var isNavigating = false
    @State private var showsTransformView = false
    @State private var showsAnimatorsView = false
    @State private var showsNewGeneratorView = false
    @State private var showsSelectedObjectInspector = false
    @State private var playableScene: SPTPlayableSceneProxy?

    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            GeometryReader { geometryProxy in
                SceneView(model: sceneViewModel,
                          uiSafeAreaInsets: geometryProxy.safeAreaInsets,
                          isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation), bottomView: {
                    if let selected = sceneViewModel.selectedObject {
                        objectActionView(selected)
                            .background(SceneViewConst.uiBgrMaterial)
                            .cornerRadius(9.0)
                            .shadow(radius: 1.0)
                            .selectedObjectUI(cornerRadius: 9.0)
                    }
                })
                    .renderingPaused(showsTransformView || showsNewGeneratorView || showsAnimatorsView || playableScene != nil)
                    .lookCategories([.userCreated, .sceneGuide, .objectSelection])
                    .navigationTitle("Generative")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                playableScene = SPTPlayableSceneProxy(scene: sceneViewModel.scene, viewCameraEntity: sceneViewModel.viewCameraObject.entity)
                            } label: {
                                Image(systemName: "play")
                            }
                        }
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button {
                                showsNewGeneratorView = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Spacer()
                            Button {
                                showsAnimatorsView = true
                            } label: {
                                Image(systemName: "circlebadge.2")
                            }
                            Spacer()
                            Button {
                                showsTransformView = true
                            } label: {
                                Image(systemName: "hammer")
                            }
                        }
                    }
                    .toolbar(isNavigating ? .hidden : .visible, for: .bottomBar, .navigationBar)
                    .statusBar(hidden: isNavigating)
                    .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $showsTransformView) {
            TransformView(sceneViewModel: sceneViewModel)
        }
        .sheet(isPresented: $showsNewGeneratorView) {
            NewObjectView() { meshId in
                let newObject = sceneViewModel.objectFactory.makeMesh(meshId: meshId)
                sceneViewModel.selectedObject = newObject
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
    
    func objectActionView(_ object: SPTObject) -> some View {
        HStack(spacing: 4.0) {
            objectActionButton(iconName: "slider.horizontal.3") {
                showsSelectedObjectInspector = true
            }
            objectActionButton(iconName: "trash") {
                sceneViewModel.destroySelected()
            }
        }
        .frame(height: 44.0)
        .padding(4.0)
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
