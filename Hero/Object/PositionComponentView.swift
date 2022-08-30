//
//  PositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI
import Combine

class PositionComponent: Component {
    
    static let title = "Position"
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var baseCancellable: AnyCancellable? = nil
    
    lazy private(set) var base = BasePositionComponent(object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var animators = PositionAnimatorBindingsComponent(object: self.object, parent: self)
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(title: Self.title, parent: parent)
        
        self.baseCancellable = base.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    override var subcomponents: [Component]? { [base, animators] }
    
}


struct PositionComponentView: View {
    
    @ObservedObject var component: PositionComponent
    @Binding var editedComponent: Component?
    
    var body: some View {
        Section(component.title) {
            SceneEditableParam(title: component.base.title, value: String(format: "(%.2f, %.2f, %.2f)", component.base.value.x, component.base.value.y, component.base.value.z)) {
                editedComponent = component.base
            }
            NavigationLink("Animators") {
                PositionAnimatorBindingsView(component: component.animators, editedComponent: $editedComponent)
            }
        }
    }
}


class BasePositionComponent: BasicComponent<Axis> {
    
    static let title = "Base"
    
    @SPTObservedComponent var position: SPTPosition
    let sceneViewModel: SceneViewModel
    
    private var guideAxisObject: SPTObject?
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        _position = SPTObservedComponent(object: object)
        self.sceneViewModel = sceneViewModel
        
        super.init(title: Self.title, selectedProperty: .x, parent: parent)
        
        _position.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { position.xyz = newValue }
        get { position.xyz }
    }
    
    override func onActive() {
        setupGuideObjects()
    }
    
    override func onInactive() {
        removeGuideObjects()
    }
    
    override var selectedProperty: Axis? {
        didSet {
            removeGuideObjects()
            setupGuideObjects()
        }
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
    private func setupGuideObjects() {
        assert(guideAxisObject == nil)
        
        guard let property = selectedProperty else { return }
        
        let guideObject = sceneViewModel.scene.makeObject()
        SPTScaleMake(guideObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTPolylineViewDepthBiasMake(guideObject, 5.0, 3.0, 0.0)
        
        switch property {
        case .x:
            SPTPosition.make(.init(x: 0.0, y: position.xyz.y, z: position.xyz.z), object: guideObject)
            SPTPolylineViewMake(guideObject, sceneViewModel.lineMeshId, UIColor.xAxisLight.rgba, 3.0)
        case .y:
            SPTPosition.make(.init(x: position.xyz.x, y: 0.0, z: position.xyz.z), object: guideObject)
            SPTOrientationMakeEuler(guideObject, .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ))
            SPTPolylineViewMake(guideObject, sceneViewModel.lineMeshId, UIColor.yAxisLight.rgba, 3.0)
        case .z:
            SPTPosition.make(.init(x: position.xyz.x, y: position.xyz.y, z: 0.0), object: guideObject)
            SPTOrientationMakeEuler(guideObject, .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ))
            SPTPolylineViewMake(guideObject, sceneViewModel.lineMeshId, UIColor.zAxisLight.rgba, 3.0)
        }
        
        guideAxisObject = guideObject
    }
    
    private func removeGuideObjects() {
        guard let object = guideAxisObject else { return }
        SPTScene.destroy(object)
        guideAxisObject = nil
    }
    
}


struct EditBasePositionComponentView: View {
    
    @ObservedObject var component: BasePositionComponent
    @State private var scale = FloatSelector.Scale._1
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatSelector(value: $component.value[axis.rawValue], scale: $scale)
                .transition(.identity)
                .id(axis.rawValue)
        }
    }
}
