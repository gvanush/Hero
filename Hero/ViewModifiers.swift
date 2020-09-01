//
//  ViewModifiers.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI

struct MinTappableFrame: ViewModifier {
    
    private let alignemnt: Alignment
    
    init(alignment: Alignment) {
        self.alignemnt = alignment
    }
    
    func body(content: Content) -> some View {
        content.frame(minWidth: (alignemnt.horizontal == .center ? 44 : nil), idealWidth: nil, maxWidth: nil, minHeight: (alignemnt.vertical == .center ? 44 : nil), idealHeight: nil, maxHeight: nil, alignment: alignemnt)
    }
    
}

extension View {
    func minTappableFrame(alignment: Alignment) -> some View {
        self.modifier(MinTappableFrame(alignment: alignment))
    }
}
