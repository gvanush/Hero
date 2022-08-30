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
                    .renderingPaused(showsTransformView || showsNewGeneratorView)
                    .navigationTitle("Generative")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
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
        .fullScreenCover(isPresented: $showsTransformView, onDismiss: nil) {
            TransformView(sceneViewModel: sceneViewModel)
        }
        .fullScreenCover(isPresented: $showsNewGeneratorView, onDismiss: nil) {
            NewGeneratorView()
                .environmentObject(sceneViewModel)
        }
        .sheet(isPresented: $showsAnimatorsView) {
            AnimatorsView()
        }
        .sheet(isPresented: $showsSelectedObjectInspector) {
            MeshObjectInspector(meshComponent: MeshObjectComponent(object: sceneViewModel.selectedObject!, sceneViewModel: sceneViewModel))
                .environmentObject(sceneViewModel)
        }
    }
    
    func objectActionView(_ object: SPTObject) -> some View {
        HStack(spacing: 4.0) {
            objectActionButton(iconName: "slider.horizontal.3") {
                showsSelectedObjectInspector = true
            }
            objectActionButton(iconName: "trash") {
                
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
