//
//  Views.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI

struct NavigationBarBgr: View {
    
    let topPadding: CGFloat
    
    var body: some View {
        HStack {
            Spacer()
        }
        .frame(width: nil, height: 44.0, alignment: .center)
        .background(Material.bar)
        .compositingGroup()
        .shadow(color: .defaultShadowColor, radius: 0.0, x: 0, y: 0.5)
        .padding(.top, topPadding)
    }
}


struct ToolbarBgr: View {
    
    let bottomPadding: CGFloat
    
    var body: some View {
        HStack {
            Spacer()
        }
        .frame(width: nil, height: 44.0, alignment: .center)
        .background(Material.bar)
        .compositingGroup()
        .shadow(color: .defaultShadowColor, radius: 0.0, x: 0, y: -0.5)
        .padding(.bottom, bottomPadding)
    }
}
