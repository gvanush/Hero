//
//  HSBAColorElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.05.23.
//

import SwiftUI


struct HSBAColorElement<C>: Element
where C: SPTInspectableComponent {
    
    typealias Property = HSBColorChannel
    
    let object: SPTObject
    let keyPath: WritableKeyPath<C, SPTColor>
    
    @ObjectComponentActiveProperty var activeProperty: Property
    @StateObject var hsba: SPTObservableComponentProperty<C, SPTHSBAColor>
    
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, SPTColor>) {
        self.object = object
        self.keyPath = keyPath
        _activeProperty = .init(object: object, componentId: keyPath)
        _hsba = .init(wrappedValue: .init(object: object, keyPath: keyPath.appending(path: \.hsba)))
    }
    
    var actionView: some View {
        HSBColorSelector(hsbaColor: $hsba.value, channel: activeProperty) { isEditing in
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
        "HSB"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
