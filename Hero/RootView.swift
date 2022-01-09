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
    
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                ZStack {
                    SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.easeIn(duration: 0.15)), isRenderingPaused: showsTransformView)
                    VStack {
                        NavigationBarBgr(topPadding: geometryProxy.safeAreaInsets.top)
                        Spacer()
                        ToolbarBgr(bottomPadding: geometryProxy.safeAreaInsets.bottom)
                    }
                    .opacity(isNavigating ? 0.0 : 1.0)
                    
                }
                .navigationTitle("Generative")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(isNavigating)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        toolbarButton(iconName: "circle.hexagongrid.circle") {
                            print("Pressed")
                        }
                        Spacer()
                        toolbarButton(iconName: "hammer.circle") {
                            showsTransformView = true
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $showsTransformView, onDismiss: nil) {
            TransformView(sceneViewModel: sceneViewModel)
        }
        // TODO: This causes nivagtion title to animate vertically when 'isNavigating' changes
        // .statusBar(hidden: isNavigating)
    }
    
    func toolbarButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
        }
        .opacity(isNavigating ? 0.0 : 1.0)
    }
    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}


fileprivate struct NavigationBar: View {
    
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
            Spacer()
            
        }
        .frame(maxHeight: Self.height)
        .background(Material.bar)
        .compositingGroup()
        .shadow(color: .defaultShadowColor, radius: 0.0, x: 0, y: 0.5)
    }
    
    static let height = 44.0
}
