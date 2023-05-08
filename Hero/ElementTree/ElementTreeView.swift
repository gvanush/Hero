//
//  ElementTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI

let elementOptionsViewMatchedGeometryID = "elementOptionsViewMatchedGeometryID"
let elementActionViewMatchedGeometryID = "elementActionViewMatchedGeometryID"
let elementNavigationAnimation = Animation.easeOut(duration: 0.25)
let elementPropertyNavigationAnimation = Animation.easeOut(duration: 0.25)


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
            .padding(3.0)
            .frame(height: 38.0)
            .background(content: {
                Color.clear
                    .background(Material.regular)
                    .cornerRadius(SelectorConst.cornerRadius)
                    .compositingGroup()
                    .shadow(radius: 1.0)
            })
    }
    
}


fileprivate struct LeafElement<ID>: Element
where ID: Hashable {
    
    enum Property: ElementProperty {
        case x
        case y
        case z
    }
    
    let id: ID
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @State var activeProperty: Property
    @State var model: simd_float3 = .zero
    
    @Namespace var namespace
    
    init(id: ID, title: String, activeProperty: Property) {
        self.id = id
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

struct ElementTreeView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var activeIndexPath = IndexPath()
        
        @State var selector = false
        
        var body: some View {
            VStack {
                
                ElementTreeView(activeIndexPath: $activeIndexPath) {
                    CompositeElement(id: "Ancestor", title: "Ancestor") {
                        CompositeElement(id: "Parent", title: "Parent") {
                            if selector {
                                LeafElement(id: "Leaf1", title: "Leaf1", activeProperty: .x)
                            } else {
                                
                                LeafElement(id: "Leaf2", title: "Leaf2", activeProperty: .x)
                            }
                        }
                        LeafElement(id: "Leaf3", title: "Leaf3", activeProperty: .x)
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
