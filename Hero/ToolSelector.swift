//
//  ToolSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.10.22.
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


struct ToolSelector: View {
    
    @Binding var tool: Tool
    
    private var horizontalPadding: CGFloat = 0.0
    @Namespace private var matchedGeometryEffectNamespace
    
    init(_ tool: Binding<Tool>) {
        _tool = tool
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Tool.allCases) { tool in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            self.tool = tool
                        }
                    } label: {
                        Image(tool.iconName)
                            .imageScale(.large)
                            .shadow(radius: 0.5)
                            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8.0)
                            .foregroundColor(.systemFill)
                            .visible(self.tool == tool)
                            .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: self.tool == tool)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .tint(.primary)
    }
    
    func contentHorizontalPadding(_ padding: CGFloat) -> ToolSelector {
        var selector = self
        selector.horizontalPadding = padding
        return selector
    }
    
    static let itemSize = CGSize(width: 48.0, height: 48.0)
}

struct ToolSelector_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var tool = Tool.inspect
        
        var body: some View {
            ToolSelector($tool)
                .contentHorizontalPadding(16.0)
        }
    }
    
    static var previews: some View {
        ContentView()
    }
}
