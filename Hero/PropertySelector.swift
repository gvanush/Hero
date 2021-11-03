//
//  PropertySelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

protocol PropertySelectorItem: CaseIterable, Identifiable, Equatable {
    var displayText: String { get }
}

struct PropertySelector<PT>: View where PT: PropertySelectorItem, PT.AllCases: RandomAccessCollection {
    
    @Binding var selected: PT
    @State private var selectedItemFrameRect: CGRect?
    
    var body: some View {
        ZStack {
            if let selectedItemFrameRect = self.selectedItemFrameRect {
                RoundedRectangle(cornerRadius: selectionCornerRadius)
                    .foregroundColor(.systemFill)
                    .frame(width: selectedItemFrameRect.width, height: selectedItemFrameRect.height)
                    .position(selectedItemFrameRect.center)
            }
            
            items
            
        }
        .coordinateSpace(name: rootCoordinateSpaceName)
        .frame(maxWidth: .infinity, idealHeight: height)
        .fixedSize(horizontal: false, vertical: true)
        .background(bgrMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.orange, lineWidth: selectionBorderLineWidth))
    }
    
    private var items: some View {
        HStack(spacing: 0.0) {
            ForEach(PT.allCases) { property in
                itemFor(property)
            }
        }
        .onPreferenceChange(SelectedItemFrameRectPreferenceKey.self) { frameRect in
            if selectedItemFrameRect == nil {
                selectedItemFrameRect = frameRect
            } else {
                withAnimation(.easeOut(duration: selectionAnimationDuration)) {
                    selectedItemFrameRect = frameRect
                }
            }
        }
    }
    
    func itemFor(_ property: PT) -> some View {
        GeometryReader { geometry in
            Text(property.displayText)
                .foregroundColor(.white)
                .colorMultiply(property == selected ? Color.white : Color.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, textHorizontalPadding)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: SelectedItemFrameRectPreferenceKey.self, value: (property == selected ? geometry.frame(in: CoordinateSpace.named(rootCoordinateSpaceName)) : nil))
                    }
                )
                .padding(itemPadding)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0.0)
                            .onEnded({ value in
                    if CGRect(origin: .zero, size: geometry.size).contains(value.location) {
                        selected = property
                    }
                }))
        }
    }
    
    let rootCoordinateSpaceName = "root"
    let height = 38.0
    let cornerRadius = 19.0
    let shadowRadius = 2.0
    let bgrMaterial = Material.bar
    let itemPadding = 3.0
    let textHorizontalPadding = 8.0
    let selectionCornerRadius = 16.0
    let selectionBorderLineWidth = 1.0
    let selectionAnimationDuration = 0.2
}

fileprivate struct SelectedItemFrameRectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect?
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        if value == nil {
            value = nextValue()
        }
    }
}
