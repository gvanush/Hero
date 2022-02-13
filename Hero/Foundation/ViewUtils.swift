//
//  ViewModifiers.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

import SwiftUI

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
    
    func visible(_ visible: Bool) -> some View {
        self.opacity(visible ? 1.0 : 0.0)
    }
}


protocol Displayable {
    var displayName: String { get }
}

extension Displayable {
    var displayName: String {
        String(describing: self).capitalizingFirstLetter()
    }
}

extension Displayable where Self: CaseIterable {
    
    static var allCaseDisplayNames: [String] {
        Self.allCases.map { $0.displayName }
    }
    
}
