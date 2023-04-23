//
//  ElementTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI

let elementSelectionViewHeight = 38.0

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
                .frame(height: elementSelectionViewHeight)
                .background(content: {
                    Color.clear
                        .background(Material.regular)
                        .cornerRadius(SelectorConst.cornerRadius)
                        .compositingGroup()
                        .shadow(radius: 1.0)
                    
                })
        }
    }
    
}


struct LeafElement: Element {
    
    enum Property: ElementProperty {
        case x
        case y
        case z
    }
    
    let title: String
    let actionViewColor: Color
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @State var activeProperty: Property
    @State var model: simd_float3 = .zero
    
    @Namespace var namespace
    
    init(title: String, activeProperty: Property, actionViewColor: Color = .red) {
        self.title = title
        self.actionViewColor = actionViewColor
        _activeProperty = .init(wrappedValue: activeProperty)
    }
    
    var actionView: some View {
        switch activeProperty {
        case .x:
            Color.red
        case .y:
            Color.green
        case .z:
            Color.blue
        }
    }
}

struct TestElement: Element {
    
    var title: String {
        "TestElement"
    }
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @Namespace var namespace
    
    var content: some Element {
        LeafElement(title: "L1", activeProperty: .x, actionViewColor: .red)
        LeafElement(title: "L2", activeProperty: .x, actionViewColor: .green)
        LeafElement(title: "L3", activeProperty: .x, actionViewColor: .blue)
        LeafElement(title: "L4", activeProperty: .x, actionViewColor: .yellow)
        LeafElement(title: "L5", activeProperty: .x, actionViewColor: .cyan)
    }
    
}


struct ElementTreeView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var activeIndexPath = IndexPath()
        
        @State var selector = false
        
        var body: some View {
            VStack {
                
                ElementTreeView(activeIndexPath: $activeIndexPath) {
                    CompositeElement(title: "Ancestor") {
                        CompositeElement(title: "Parent") {
                            if selector {
                                LeafElement(title: "Leaf1", activeProperty: .x)
                            } else {
                                LeafElement(title: "Leaf2", activeProperty: .y)
                            }
                        }
                        LeafElement(title: "Leaf3", activeProperty: .x)
                        TestElement()
                    }
                }
                
                HStack {
                    Button("Back") {
                        withAnimation(elementNavigationAnimation) {
                            _ = activeIndexPath.removeLast()
                        }
                    }
                    .disabled(activeIndexPath.isEmpty)
                    
                    Spacer()
                    
                    Button("Toggle") {
                        withAnimation(elementNavigationAnimation) {
                            selector.toggle()
                        }
                    }
                }
                .padding()
            }
            .onChange(of: activeIndexPath) { newValue in
                print("active index path: \(newValue)")
            }
        }
        
    }
    
    static var previews: some View {
        ContentView()
            .padding()
    }
}
