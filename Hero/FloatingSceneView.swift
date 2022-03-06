//
//  FloatingSceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

struct FloatingSceneView: View {
    
    private let closedStateSize: CGSize
    private let isRenderingPaused: Bool
    @State private var isOpened = false
    @State private var isNavigating = false
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    init(closedStateSize: CGSize, isRenderingPaused: Bool = false) {
        self.closedStateSize = closedStateSize
        self.isRenderingPaused = isRenderingPaused
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer(minLength: 0.0)
                ZStack {
                    SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation), isRenderingPaused: isRenderingPaused, isNavigationEnabled: isOpened, isSelectionEnabled: false)
                        .cornerRadius(isOpened ? 0.0 : Self.cornerRadius)
                        .shadow(radius: Self.shadowRadius)
                    VStack {
                        Spacer(minLength: 0.0)
                        ZStack {
                            VStack {
                                Spacer(minLength: 0.0)
                                Button {
                                    withAnimation {
                                        isOpened = false
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: isOpened ? Self.closeButtonWidth : 0.0,
                                               height: isOpened ? Self.closeButtonHeight : 0.0)
                                        .cornerRadius(Self.cornerRadius)
                                        .shadow(radius: Self.shadowRadius)
                                        .visible(isOpened && !isNavigating)
                                }
                                .padding(.bottom)
                                .allowsHitTesting(isOpened)
                            }
                            
                            if !isOpened {
                                Button {
                                    withAnimation {
                                        isOpened = true
                                    }
                                } label: {
                                    Color.clear
                                        .frame(width: isOpened ? 0.0 : closedStateSize.width,
                                               height: isOpened ? 0.0 : closedStateSize.height)
                                }
                            }
                        }
                        .padding(.bottom, isOpened ? geo.safeAreaInsets.bottom : 0.0)
                    }
                }
                .frame(maxWidth: isOpened ? .infinity : closedStateSize.width,
                       maxHeight: isOpened ? .infinity : closedStateSize.height)
                .padding(.trailing, isOpened ? 0.0 : Self.trailingPadding)
                
            }
            .edgesIgnoringSafeArea(isOpened ? .all : .init(rawValue: 0))
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottomTrailing)
        }
    }
    
    static let closeButtonWidth: CGFloat = 60.0
    static let closeButtonHeight: CGFloat = 60.0
    static let trailingPadding: CGFloat = 8.0
    static let cornerRadius: CGFloat = 10.0
    static let shadowRadius: CGFloat = 5.0
}

struct FloatingSceneView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingSceneView(closedStateSize: CGSize(width: 50.0, height: 150.0))
            .environmentObject(SceneViewModel())
    }
}
