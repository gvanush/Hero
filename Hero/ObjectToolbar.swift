//
//  ObjectToolbar.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11/2/20.
//

import SwiftUI

enum ObjectTool: CaseIterable {
    case move
    case scale
    case rotate
    
    var iconName: String {
        switch self {
        case .move:
            return "move.3d"
        case .scale:
            return "scale.3d"
        case .rotate:
            return "rotate.3d"
        }
    }
}

struct ObjectToolbarItem: View {
    
    let iconName: String
    let onSelected: () -> Void
        
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 25, weight: .regular))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelected)
    }
}

struct ObjectToolbar: View {
    
    @State var selectedTool = ObjectTool.move
    
    var body: some View {
        HStack(alignment: .center, spacing: 0.0) {
            ForEach(ObjectTool.allCases, id: \.self) {tool in
                ObjectToolbarItem(iconName: tool.iconName) {
                    self.selectedTool = tool
                }
                .foregroundColor(tool == selectedTool ? Color.accentColor : Color(.tertiaryLabel))
            }
        }
    }
}

