//
//  ElementTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI

let elementSelectionViewHeight = 38.0
let elementSelectionViewPadding = 3.0


struct ElementTreeView<RE>: View where RE: Element {

    let rootElement: RE

    @Binding var activeIndexPath: IndexPath
    
    init(activeIndexPath: Binding<IndexPath>, @ElementBuilder rootElement: () -> RE) {
        _activeIndexPath = activeIndexPath
        self.rootElement = rootElement()
    }


    var body: some View {
        rootElement
            .indexPath(.init(index: 0))
            .activeIndexPath($activeIndexPath)
            .padding(elementSelectionViewPadding)
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


fileprivate struct LeafElement: Element {
    
    enum Property: ElementProperty {
        case x
        case y
        case z
    }
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @State var activeProperty: Property
    @State var model: simd_float3 = .zero
    
    @Namespace var namespace
    
    init(title: String, activeProperty: Property) {
        self.title = title
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
    
    var faceView: some View {
        Text(title)
            .font(.callout)
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, -3.0)
            }
    }
}

fileprivate struct TestElement: Element {
    
    var title: String {
        "TestElement"
    }
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @Namespace var namespace
    
    var content: some Element {
        LeafElement(title: "L1", activeProperty: .x)
        LeafElement(title: "L2", activeProperty: .x)
        LeafElement(title: "L3", activeProperty: .x)
        LeafElement(title: "L4", activeProperty: .x)
        LeafElement(title: "L5", activeProperty: .x)
    }
    
    var faceView: some View {
        Text(title)
            .font(.callout)
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, -3.0)
            }
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
                                TestElement()
                                LeafElement(title: "Leaf1", activeProperty: .x)
                            } else {
                                
                                LeafElement(title: "Leaf1", activeProperty: .x)
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
