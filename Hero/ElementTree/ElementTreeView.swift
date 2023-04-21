//
//  ElementTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI

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

struct TestElement: Element {
    
    var title: String {
        "TestElement"
    }
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @Namespace var namespace
    
    var content: some Element {
        LeafElement(title: "L1", activeProperty: Axis.x)
        LeafElement(title: "L2", activeProperty: Axis.x)
        LeafElement(title: "L3", activeProperty: Axis.x)
        LeafElement(title: "L4", activeProperty: Axis.x)
        LeafElement(title: "L5", activeProperty: Axis.x)
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
                                LeafElement(title: "Leaf1", activeProperty: Axis.x)
                            }
                            LeafElement(title: "Leaf2", activeProperty: Axis.x)
                        }
                        LeafElement(title: "Leaf3", activeProperty: Axis.x)
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
