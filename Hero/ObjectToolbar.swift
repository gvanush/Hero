//
//  ObjectToolbar.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/22/20.
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
    
    let tool: ObjectTool
    let onSelected: () -> Void
        
    var body: some View {
        Image(systemName: tool.iconName)
            .font(.system(size: 25, weight: .regular))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelected)
    }
}

struct ObjectToolbar: View {
    
    @State var selectedTool = ObjectTool.move
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                HStack(alignment: .center, spacing: 0.0) {
                    ForEach(ObjectTool.allCases, id: \.self) {tool in
                        ObjectToolbarItem(tool: tool) {
                            self.selectedTool = tool
                        }
                        .foregroundColor(tool == selectedTool ? Color.accentColor : Color.white.opacity(0.7))
                    }
                }
//                .padding()
                .frame(minWidth: proxy.size.width, idealWidth: proxy.size.width, maxWidth: proxy.size.width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .leading)
                .padding(.bottom, proxy.safeAreaInsets.bottom)
                .background(BlurView(style: .systemUltraThinMaterial))
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    let height: CGFloat = 50.0
}

struct ObjectToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ObjectToolbar()
    }
}
