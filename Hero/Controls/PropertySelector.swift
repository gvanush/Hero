//
//  PropertySelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI


struct PropertySelector<PT>: View where PT: DistinctValueSet & Displayable, PT.AllCases: RandomAccessCollection {

    @Binding var selected: PT
    @Namespace private var matchedGeometryEffectNamespace
    
    var body: some View {
        items
            .frame(maxWidth: .infinity, idealHeight: SelectorConst.height)
            .fixedSize(horizontal: false, vertical: true)
            .background(SelectorConst.bgrMaterial, in: RoundedRectangle(cornerRadius: SelectorConst.cornerRadius))
            .compositingGroup()
            .shadow(radius: 1.0)
    }
    
    private var items: some View {
        HStack(spacing: 0.0) {
            ForEach(PT.allCases) { property in
                itemFor(property)
            }
        }
    }
    
    func itemFor(_ property: PT) -> some View {
        GeometryReader { geometry in
            Text(property.displayName)
                .foregroundColor(.white)
                .colorMultiply(property == selected ? Color.white : Color.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, SelectorConst.textHorizontalPadding)
                .background {
                    RoundedRectangle(cornerRadius: SelectorConst.selectionCornerRadius)
                        .foregroundColor(.systemFill)
                        .visible(property == selected)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: property == selected)
                }
                .padding(SelectorConst.itemPadding)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0.0)
                            .onEnded({ value in
                    if CGRect(origin: .zero, size: geometry.size).contains(value.location) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selected = property
                        }
                    }
                }))
        }
    }
    
}


struct SelectorConst {
    static let height = 38.0
    static let cornerRadius = 19.0
    static let bgrMaterial = Material.regular
    static let itemPadding = 3.0
    static let textHorizontalPadding = 8.0
    static let selectionCornerRadius = 16.0
}


struct Selector_Previews: PreviewProvider {
    
    struct ContainerView: View {
        
        @State var axis = Axis.x
        
        var body: some View {
            PropertySelector(selected: $axis)
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
