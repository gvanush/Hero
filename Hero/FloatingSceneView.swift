//
//  FloatingSceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

struct FloatingSceneView: View {
    
    @State private var isOpened = false
    @State private var isNavigating = false
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer(minLength: 0.0)
                ZStack {
                    SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.easeInOut(duration: 0.15)), isUIHidden: !isOpened)
                        .cornerRadius(isOpened ? 0.0 : Self.cornerRadius)
                        .shadow(radius: Self.shadowRadius)
                    VStack {
                        Spacer(minLength: 0.0)
                        ZStack {
                            Button {
                                withAnimation {
                                    isOpened = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .imageScale(.large)
                                    .frame(width: Self.closeButtonWidth, height: Self.closeButtonHeight)
                                    .background(Material.bar, ignoresSafeAreaEdges: .init(rawValue: 0))
                                    .cornerRadius(Self.cornerRadius)
                                    .shadow(radius: Self.shadowRadius)
                                    .opacity(isOpened && !isNavigating ? 1.0 : 0.0)
                            }
                            
                            Button {
                                withAnimation {
                                    isOpened = true
                                }
                            } label: {
                                Color.clear
                                    .frame(width: Self.closedStateWidth, height: Self.closedStateHeight)
                            }
                            .allowsHitTesting(!isOpened)
                        }
                        .padding(.bottom, isOpened ? geo.safeAreaInsets.bottom : 0.0)
                    }
                }
                .frame(maxWidth: isOpened ? .infinity : Self.closedStateWidth,
                       maxHeight: isOpened ? .infinity : Self.closedStateHeight)
                
            }
            .edgesIgnoringSafeArea(isOpened ? .all : .init(rawValue: 0))
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
    
    static let closedStateWidth: CGFloat = 120.0
    static let closedStateHeight: CGFloat = 60.0
    static let closeButtonWidth: CGFloat = 60.0
    static let closeButtonHeight: CGFloat = 60.0
    static let cornerRadius: CGFloat = 10.0
    static let shadowRadius: CGFloat = 5.0
}

struct FloatingSceneView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingSceneView()
            .environmentObject(SceneViewModel())
    }
}
