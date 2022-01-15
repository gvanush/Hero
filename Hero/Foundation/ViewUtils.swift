//
//  ViewModifiers.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

import SwiftUI

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        return self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
