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
        GeometryReader { proxy in
            VStack {
                Spacer()
                ZStack(alignment: .top) {
                    HStack(alignment: .center, spacing: 0.0) {
                        ForEach(ObjectTool.allCases, id: \.self) {tool in
                            ObjectToolbarItem(iconName: tool.iconName) {
                                self.selectedTool = tool
                            }
                            .foregroundColor(tool == selectedTool ? Color.accentColor : Color.white.opacity(0.5))
                        }
                        ObjectToolbarItem(iconName: "ellipsis") {
                            
                        }
                        .foregroundColor(Color.white)
                    }
//                        .padding()
                        .frame(minWidth: proxy.size.width, idealWidth: proxy.size.width, maxWidth: proxy.size.width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .center)
                        .padding(.bottom, proxy.safeAreaInsets.bottom)
                        .background(BlurView(style: .systemUltraThinMaterial))
                        
                    Image(systemName: "minus")
                        .font(.system(size: 45, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.5))
                        .offset(x: 0, y: 7.0)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    let height: CGFloat = 60.0
}

struct ObjectToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ObjectToolbar()
    }
}
