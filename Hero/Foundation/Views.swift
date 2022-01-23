//
//  Views.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.22.
//

import SwiftUI


struct BottomBar: View {
    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: Self.height)
            .background(Material.bar)
            .compositingGroup()
            .shadow(radius: 0.5)
    }
    
    static let height: CGFloat = 49.0
}
