//
//  ContentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.10.21.
//

import SwiftUI

enum Axis: PropertySelectorItem {
    
    case x
    case y
    case z
    
    var id: Self { self }
    
    var displayText: String {
        switch self {
        case .x:
            return "X"
        case .y:
            return "Y"
        case .z:
            return "Z"
        }
    }
}

struct TransformView: View {
    
    @State var tool = Tool.move
    @State var axis = Axis.x
    @State var isNavigating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                SceneView(isNavigating: $isNavigating)
                VStack(spacing: Self.controlsMargin) {
                    Spacer()
                    controls
                        .padding(.horizontal, Self.controlsMargin)
                    Toolbar(selection: $tool)
                }
                .opacity(isNavigating ? 0.0 : 1.0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(tool.title)
            .navigationBarHidden(isNavigating)
        }
        // TODO: Remove when the bug is fixed (Needed to avoid iOS auto-layout warnings on startup)
        .navigationViewStyle(.stack)
    }
    
    var controls: some View {
        VStack(spacing: Self.controlsSpacing) {
            PropertySelector(selected: $axis)
        }
    }
    
    static let controlsMargin = 8.0
    static let controlsSpacing = 8.0
    
    enum Tool: CaseIterable, Identifiable {
        
        case move
        case orient
        case scale
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .move:
                return "Move"
            case .orient:
                return "Orient"
            case .scale:
                return "Scale"
            }
        }
        
        var image: String {
            switch self {
            case .move:
                return "move.3d"
            case .orient:
                return "rotate.3d"
            case .scale:
                return "scale.3d"
            }
        }
    }
    
    struct Toolbar: View {
        
        @Binding var selection: Tool
        
        var body: some View {
            HStack(spacing: 0.0) {
                ForEach(Tool.allCases) { tool in
                    itemFor(tool)
                        .foregroundColor(selection == tool ? .accentColor : .gray)
                        .onTapGesture {
                            selection = tool
                        }
                }
            }
            .padding(.top, Self.topPadding)
            .background(Material.bar)
            .compositingGroup()
            .shadow(color: .defaultShadowColor, radius: 0.0, x: 0, y: -0.5)
        }
        
        static let topPadding = 4.0
        
        func itemFor(_ tool: Tool) -> some View {
            Label(tool.title, systemImage: tool.image)
                .labelStyle(ItemLabelStyle())
                .frame(maxWidth: .infinity, minHeight: Self.itemHeight)
        }
        
        static let itemHeight = 44.0
        
        struct ItemLabelStyle: LabelStyle {
            func makeBody(configuration: Configuration) -> some View {
                VStack(alignment: .center, spacing: Self.iconTextSpacing) {
                    configuration.icon.imageScale(.large)
                    configuration.title.font(.system(.caption2))
                }
            }
            
            static let iconTextSpacing = 2.0
        }
        
    }
    
}

struct TransformView_Previews: PreviewProvider {
    static var previews: some View {
        TransformView()
    }
}
