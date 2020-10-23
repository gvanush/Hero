//
//  ObjectToolbar.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/22/20.
//

import SwiftUI

enum ObjectTool {
    case move
    case scale
    case rotate
}

struct SceneToolbarItem {
    var body: some View {
        Image(systemName: "move.3d")
            .font(.system(size: 25, weight: .regular))
    }
}

struct ObjectToolbar: View {
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                HStack(spacing: 20.0) {
                    Image(systemName: "move.3d")
                        .font(.system(size: 25, weight: .regular))
                    Image(systemName: "scale.3d")
                        .font(.system(size: 25, weight: .regular))
                    Image(systemName: "rotate.3d")
                        .font(.system(size: 25, weight: .regular))
                }
                .padding()
                .frame(minWidth: proxy.size.width, idealWidth: proxy.size.width, maxWidth: proxy.size.width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .leading)
                .padding(.bottom, proxy.safeAreaInsets.bottom)
                .background(BlurView(style: .systemUltraThinMaterial))
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    let height: CGFloat = 50.0
}

struct SceneToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ObjectToolbar()
    }
}
