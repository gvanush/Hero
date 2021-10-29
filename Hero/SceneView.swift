//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.21.
//

import SwiftUI

struct SceneView: View {
    
    @ObservedObject var model: SceneViewModel
    @Binding var isNavigating: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @State private var clearColor = UIColor.sceneBgrColor.mtlClearColor
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                 
                SptView(scene: model.scene, clearColor: $clearColor)
                    .gesture(orbitDragGesture)
                    .onLocatedTapGesture { location in
                        if let object = model.pickObjectAt(location, viewportSize: geometry.size) {
                            model.select(object)
                        } else {
                            model.discardSelection()
                        }
                    }
                    .allowsHitTesting(!isNavigating)
                    .onChange(of: colorScheme) { _ in
                        clearColor = UIColor.sceneBgrColor.mtlClearColor
                    }
                
                ui(viewportSize: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    func ui(viewportSize: CGSize) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZoomView()
                    .padding(.trailing, Self.margin)
                    .contentShape(Rectangle())
                    .gesture(zoomDragGesture(viewportSize: viewportSize))
                    .opacity(isNavigating ? 0.0 : 1.0)
            }
            .padding(.bottom, Self.uiBottomPadding)
        }
    }
    
    var orbitDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    isNavigating = true
                }
                model.orbit(dragValue: value)
            }
            .onEnded { value in
                withAnimation {
                    isNavigating = false
                }
                model.finishOrbit(dragValue: value)
            }
    }
    
    func zoomDragGesture(viewportSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                withAnimation {
                    isNavigating = true
                }
                model.zoom(dragValue: value, viewportSize: viewportSize)
            }
            .onEnded { value in
                withAnimation {
                    isNavigating = false
                }
                model.finishZoom(dragValue: value, viewportSize: viewportSize)
            }
    }
    
    static let margin = 8.0
    static let uiBottomPadding = 260.0
    static let uiElementBorderLineWidth = 0.5
    static let uiElementBackgroundMaterial = Material.thinMaterial
}

fileprivate struct ZoomView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "plus.magnifyingglass")
                .foregroundColor(.primary)
            
            GeometryReader { geometry in
                Path { path in
                    let x = 0.5 * (geometry.size.width - Self.dashWidth)
                    var y = 0.0
                    repeat {
                        path.addRect(CGRect(x: x, y: y, width: Self.dashWidth, height: Self.dashHeight))
                        y += (Self.dashSpacing + Self.dashHeight)
                    } while y + Self.dashHeight < geometry.size.height
                }
                .foregroundColor(.primary)
            }
            Image(systemName: "minus.magnifyingglass")
                .foregroundColor(.primary)
        }
        .padding(Self.padding)
        .frame(width: Self.width, height: Self.height, alignment: .center)
        .background(SceneView.uiElementBackgroundMaterial, in: RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).stroke(Color.defaultShadowColor, lineWidth: SceneView.uiElementBorderLineWidth))
        
    }
    
    static let width = 28.0
    static let height = 224.0
    static let padding = 4.0
    static let cornerRadius = 7.0
    static let dashWidth = 4.0
    static let dashHeight = 1.0
    static let dashSpacing = 4.0
    
}

struct SceneView_Previews: PreviewProvider {
    
    struct SceneViewContainer: View {
        
        @StateObject var model = SceneViewModel()
        
        var body: some View {
            SceneView(model: model, isNavigating: .constant(false))
        }
    }
    
    static var previews: some View {
        SceneViewContainer()
    }
}
