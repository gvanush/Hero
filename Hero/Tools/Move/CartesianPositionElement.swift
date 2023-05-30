//
//  CartesianPositionElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.04.23.
//

import SwiftUI


struct CartesianPositionElement<C, OV>: Element
where C: SPTInspectableComponent, OV: View {
    
    enum Property: Int, ElementProperty {
        case x
        case y
        case z
    }
    
    let object: any UserObject
    let keyPath: WritableKeyPath<C, simd_float3>
    @Binding private var cartesian: simd_float3
    
    @EnvironmentObject var scene: MainScene
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    @ObjectElementActiveProperty var activeProperty: Property
    @State private var guideLine: AxisLine?
    
    let optionsView: OV
    
    init(title: String = "Position", subtitle: String? = "Cartesian", object: any UserObject, keyPath: WritableKeyPath<C, simd_float3>, position: Binding<simd_float3>, @ViewBuilder optionsView: () -> OV = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.object = object
        self.keyPath = keyPath
        self.optionsView = optionsView()
        _cartesian = position
        _activeProperty = .init(object: object.sptObject, elementId: keyPath)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .x:
                ObjectFloatPropertySelector(object: object.sptObject, id: keyPath.appending(path: \.x), value: $cartesian.x, formatter: Formatters.distance)
            case .y:
                ObjectFloatPropertySelector(object: object.sptObject, id: keyPath.appending(path: \.y), value: $cartesian.y, formatter: Formatters.distance)
            case .z:
                ObjectFloatPropertySelector(object: object.sptObject, id: keyPath.appending(path: \.z), value: $cartesian.z, formatter: Formatters.distance)
            }
        }
        .tint(controlTint)
    }
    
    func onActivePropertyChange() {
        removeGuideLine()
        setupGuideLine()
    }
    
    func onActive() {
        setupGuideLine()
    }
    
    func onInactive() {
        removeGuideLine()
    }
    
    func onDisclose() {
        onDiscloseCallback()
    }
    
    func onClose() {
        onCloseCallback()
    }
    
    private func setupGuideLine() {

        let guideLine = scene.makeObject {
            AxisLine(sptObject: $0, length: 1000.0, thickness: .guideLineRegularThickness, lookCategories: LookCategories.guide)
        }
        
        guideLine.position = .init(cartesian: cartesian)
        
        switch activeProperty {
        case .x:
            guideLine.axis = .x
            guideLine.color = .xAxisLight
        case .y:
            guideLine.axis = .y
            guideLine.color = .yAxisLight
        case .z:
            guideLine.axis = .z
            guideLine.color = .zAxisLight
        }
        
        self.guideLine = guideLine

    }
    
    private func removeGuideLine() {
        guideLine?.die()
        guideLine = nil
    }
    
    var id: some Hashable {
        keyPath
    }
    
    func controlTint(_ color: Color) -> Self {
        var copy = self
        copy.controlTint = color
        return copy
    }
    
    func onDisclose(_ callback: @escaping () -> Void) -> Self {
        var copy = self
        copy.onDiscloseCallback = callback
        return copy
    }
    
    func onClose(_ callback: @escaping () -> Void) -> Self {
        var copy = self
        copy.onCloseCallback = callback
        return copy
    }
    
    let title: String
    var subtitle: String?
    
    private var controlTint: Color = .primarySelectionColor
    private var onDiscloseCallback = {}
    private var onCloseCallback = {}
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace

}
