//
//  RGBAColorElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.05.23.
//

import SwiftUI


struct RGBAColorElement<C>: Element
where C: SPTInspectableComponent {
    
    typealias Property = RGBColorChannel
    
    let object: SPTObject
    let keyPath: WritableKeyPath<C, SPTColor>
    
    @ObjectElementActiveProperty var activeProperty: Property
    @StateObject var rgba: SPTObservableComponentProperty<C, SPTRGBAColor>
    
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, SPTColor>) {
        self.object = object
        self.keyPath = keyPath
        _activeProperty = .init(object: object, elementId: keyPath)
        _rgba = .init(wrappedValue: .init(object: object, keyPath: keyPath.appending(path: \.rgba)))
    }
    
    var actionView: some View {
        RGBColorSelector(rgbaColor: $rgba.value, channel: activeProperty) { isEditing in
            userInteractionState.isEditing = isEditing
        }
        .id(activeProperty)
        .tint(.primarySelectionColor)
        .transition(.identity)
    }
    
    var optionsView: some View {
        ObjectColorModelSelector(object: object, keyPath: keyPath)
    }
    
    var id: some Hashable {
        keyPath
    }
    
    var title: String {
        "Color"
    }
    
    var subtitle: String? {
        "RGB"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
