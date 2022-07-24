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
    
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation))
                    .renderingPaused(showsTransformView || showsNewGeneratorView)
                    .navigationTitle("Generative")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(isNavigating)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            if !isNavigating {
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
                    }
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
        
        // TODO: This causes nivagtion title to animate vertically when 'isNavigating' changes
        // .statusBar(hidden: isNavigating)
    }
    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
