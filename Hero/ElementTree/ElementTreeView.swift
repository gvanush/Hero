//
//  ElementTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI

fileprivate let navigationAnimation = Animation.easeOut(duration: 0.25)

struct ElementNodeView<E>: View where E: Element {
    
    let element: E
    let indexPath: IndexPath
    @Binding var activeIndexPath: IndexPath

    @Namespace private var matchedGeometryEffectNamespace
    
    init(element: E, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) {
        self.element = element
        self.indexPath = indexPath
        _activeIndexPath = activeIndexPath
    }

    var body: some View {
        ZStack {
            
            elementView
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
//                element.content.0.nodeView(indexPath: indexPath.appending(0), activeIndexPath: $activeIndexPath)
//                element.content.1.nodeView(indexPath: indexPath.appending(1), activeIndexPath: $activeIndexPath)
//                element.content.2.nodeView(indexPath: indexPath.appending(2), activeIndexPath: $activeIndexPath)
//                element.content.3.nodeView(indexPath: indexPath.appending(3), activeIndexPath: $activeIndexPath)
//                element.content.4.nodeView(indexPath: indexPath.appending(4), activeIndexPath: $activeIndexPath)
                
            }
        }
    }
    
    var propertiesView: some View {
        
        ForEach(Array(E.Property.allCases), id: \.self) { prop in
            Text(prop.displayName)
                .font(Font.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
                .contentShape(Rectangle())
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(prop == element.activeProperty)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: prop == element.activeProperty)
                }
                .onTapGesture {
                    withAnimation(navigationAnimation) {
//                        controller.activePropertyIndex = index
                    }
                }
        }
        
    }
    
    private var elementView: some View {
        element
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
            .contentShape(Rectangle())
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 1.0)
            }
            .scaleEffect(x: textHorizontalScale)
            .visible(isChildOfActive)
            .onTapGesture {
                withAnimation(navigationAnimation) {
                    activeIndexPath = indexPath
                }
            }
            .allowsHitTesting(isChildOfActive)
    }

    private var isActive: Bool {
        indexPath == activeIndexPath
    }
    
    private var isChildOfActive: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeIndexPath
    }
    
    private var isDisclosed: Bool {
        activeIndexPath.starts(with: indexPath)
    }
    
    private var distanceToActiveAncestor: Int? {
        guard indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return indexPath.count - activeIndexPath.count
    }
    
    private var textHorizontalScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
}


struct ElementTreeView<RE>: View where RE: Element {

    let rootElement: RE?

    @Binding var activeIndexPath: IndexPath
    
    init(activeIndexPath: Binding<IndexPath>, rootElement: () -> RE) {
        _activeIndexPath = activeIndexPath
        self.rootElement = rootElement()
    }
    
    init(activeIndexPath: Binding<IndexPath>, rootElement: () -> RE) where RE == EmptyElement {
        _activeIndexPath = activeIndexPath
        self.rootElement = nil
    }

    var body: some View {
        if let rootElement = rootElement {
            rootElement
                .indexPath(.init())
                .activeIndexPath($activeIndexPath)
                .padding(3.0)
                .frame(height: 38.0)
                .background(Material.regular)
                .cornerRadius(SelectorConst.cornerRadius)
                .compositingGroup()
                .shadow(radius: 1.0)
        }
    }
    
}


struct ElementTreeView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var activeIndexPath = IndexPath()
        
        var body: some View {
            VStack {
                
                ElementTreeView(activeIndexPath: $activeIndexPath) {
                    CompositeElement(title: "Ancestor") {
                        CompositeElement(title: "Parent") {
                            LeafElement(title: "Leaf1", activeProperty: Axis.x)
                            LeafElement(title: "Leaf2", activeProperty: Axis.x)
                        }
                        LeafElement(title: "Leaf3", activeProperty: Axis.x)
                    }
                }
                
                Button("Back") {
                    withAnimation(navigationAnimation) {
                        _ = activeIndexPath.removeLast()
                    }
                }
                .disabled(activeIndexPath.isEmpty)
            }
        }
        
    }
    
    static var previews: some View {
        ContentView()
            .padding()
    }
}
