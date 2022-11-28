//
//  CartesianPositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.11.22.
//

import SwiftUI


class CartesianPositionComponent: BasicComponent<Axis> {
    
    let storedTitle: String
    let editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, ObjectPropertyCartesianPositionEditingParams>
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let lengthFormatter = Formatters.length

    @SPTObservedComponent private(set) var position: SPTPosition
    private var guideObject: SPTObject?
    
    init(title: String, editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, ObjectPropertyCartesianPositionEditingParams>, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.storedTitle = title
        self.editingParamsKeyPath = editingParamsKeyPath
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _position = SPTObservedComponent(object: object)
        
        super.init(selectedProperty: .x, parent: parent)
        
        _position.publisher = self.objectWillChange
    }
    
    var cartesian: simd_float3 {
        set { position.cartesian = newValue }
        get { position.cartesian }
    }
    
    override var selectedProperty: Axis? {
        didSet {
            if isActive {
                removeGuideObjects()
                setupGuideObjects()
            }
        }
    }
    
    override func onActive() {
        setupGuideObjects()
    }
    
    override func onInactive() {
        removeGuideObjects()
    }
    
    func setupGuideObjects() {

        let object = sceneViewModel.scene.makeObject()
        SPTScale.make(.init(x: 500.0), object: object)
        SPTPolylineLookDepthBiasMake(object, 5.0, 3.0, 0.0)

        switch selectedProperty {
        case .x:
            SPTPosition.make(.init(x: 0.0, y: cartesian.y, z: cartesian.z), object: object)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: object)
            
        case .y:
            SPTPosition.make(.init(x: cartesian.x, y: 0.0, z: cartesian.z), object: object)
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ)), object: object)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: object)
            
        case .z:
            SPTPosition.make(.init(x: cartesian.x, y: cartesian.y, z: 0.0), object: object)
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: object)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: object)
        case .none:
            fatalError()
        }

        guideObject = object
    }
    
    func removeGuideObjects() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
    override var title: String {
        storedTitle
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
 
}


struct CartesianPositionComponentView: View {
    
    @ObservedObject var component: CartesianPositionComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .x:
                FloatSelector(value: $component.cartesian.x, scale: scaleBinding(keyPath: \.x.scale), isSnappingEnabled: isSnappingBinding(keyPath: \.x.isSnapping), formatter: component.lengthFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .y:
                FloatSelector(value: $component.cartesian.y, scale: scaleBinding(keyPath: \.y.scale), isSnappingEnabled: isSnappingBinding(keyPath: \.y.isSnapping), formatter: component.lengthFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .z:
                FloatSelector(value: $component.cartesian.z, scale: scaleBinding(keyPath: \.z.scale), isSnappingEnabled: isSnappingBinding(keyPath: \.z.isSnapping), formatter: component.lengthFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .none:
                EmptyView()
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
    func scaleBinding(keyPath: WritableKeyPath<ObjectPropertyCartesianPositionEditingParams, FloatSelector.Scale>) -> Binding<FloatSelector.Scale> {
        _editingParams.projectedValue[dynamicMember: component.editingParamsKeyPath.appending(path: keyPath)]
    }
    
    func isSnappingBinding(keyPath: WritableKeyPath<ObjectPropertyCartesianPositionEditingParams, Bool>) -> Binding<Bool> {
        _editingParams.projectedValue[dynamicMember: component.editingParamsKeyPath.appending(path: keyPath)]
    }
}
