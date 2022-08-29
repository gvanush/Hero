//
//  PropertySelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.02.22.
//

import SwiftUI


struct PropertyValueSelector<PT>: View where PT: DistinctValueSet & Displayable, PT.AllCases: RandomAccessCollection {
    
    @Binding var selected: PT
    @Namespace private var matchedGeometryEffectNamespace
    
    var body: some View {
        items
            .padding(self.itemPadding)
            .frame(maxWidth: .infinity, idealHeight: height)
            .fixedSize(horizontal: false, vertical: true)
            .background(bgrMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
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
                .colorMultiply(property == selected ? .controlValue : .objectSelectionColor)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, textHorizontalPadding)
                .background {
                    RoundedRectangle(cornerRadius: selectionCornerRadius)
                        .foregroundColor(.systemFill)
                        .visible(property == selected)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: property == selected)
                }
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
    
    let height = 50.0
    let cornerRadius = 11.0
    let bgrMaterial = Material.regular
    let itemPadding = 3.0
    let textHorizontalPadding = 8.0
    let selectionCornerRadius = 8.0
}


struct PropertyValueSelector_Previews: PreviewProvider {
    
    struct ContainerView: View {
        
        @State var axis = Axis.x
        
        var body: some View {
            PropertyValueSelector(selected: $axis)
                .padding()
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
