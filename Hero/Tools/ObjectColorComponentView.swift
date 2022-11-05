//
//  ObjectColorComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import SwiftUI

class ObjectColorComponent<C>: BasicComponent<ObjectColorComponent.Property> where C: SPTObservableComponent {

    enum Property: Int, DistinctValueSet, Displayable {
        case red
        case green
        case blue
    }
    
    struct EditingParams {
    }
    
    typealias SPTColor = RGBAColor
    
    @SPTObservedComponentProperty<C, SPTColor> var color: SPTColor
    @Published var editingParams: EditingParams
    
    init(editingParams: EditingParams, keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject, parent: Component?) {
        
        self.editingParams = editingParams
        _color = .init(object: object, keyPath: keyPath)
        
        super.init(title: "Color", selectedProperty: .red, parent: parent)
        
        _color.publisher = self.objectWillChange
    }
 
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
}

struct ObjectColorComponentView<C>: View where C: SPTObservableComponent {
    
    @ObservedObject var component: ObjectColorComponent<C>
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .red:
                RGBColorSelector(rgbaColor: $component.color, component: .red)
            case .green:
                RGBColorSelector(rgbaColor: $component.color, component: .green)
            case .blue:
                RGBColorSelector(rgbaColor: $component.color, component: .blue)
            case .none:
                EmptyView()
            }
        }
        .tint(.primarySelectionColor)
        .transition(.identity)
    }
}
