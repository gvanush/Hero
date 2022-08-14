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
        let rawStr = String(describing: self).capitalizingFirstLetter()
        
        guard !rawStr.isEmpty else { return "<undefined>" }
        
        var displayStr = rawStr.prefix(1).capitalized
        
        for c in rawStr[rawStr.index(after: rawStr.startIndex)..<rawStr.endIndex] {
            if c.isNumber || c.isUppercase {
                displayStr.append(" ")
            }
            displayStr.append(c)
        }
        
        return displayStr
    }
}

extension Displayable where Self: CaseIterable {
    
    static var allCaseDisplayNames: [String] {
        Self.allCases.map { $0.displayName }
    }
    
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
