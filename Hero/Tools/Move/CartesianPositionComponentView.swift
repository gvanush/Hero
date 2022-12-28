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
    let distanceFormatter = Formatters.distance
    var objectSelectionColor = UIColor.primarySelectionColor

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
    
    override var selectedProperty: Axis {
        didSet {
            if isActive {
                removeGuideObject()
                setupGuideObject()
            }
        }
    }
    
    override func onActive() {
        setupGuideObject()
    }
    
    override func onInactive() {
        removeGuideObject()
    }
    
    func setupGuideObject() {

        let guide = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)

        switch selectedProperty {
        case .x:
            SPTScale.make(.init(x: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .y:
            SPTScale.make(.init(y: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .z:
            SPTScale.make(.init(z: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
        }

        guideObject = guide
    }
    
    func removeGuideObject() {
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
                FloatSelector(value: $component.cartesian.x, scale: editingParamBinding(keyPath: \.x.scale), isSnappingEnabled: editingParamBinding(keyPath: \.x.isSnapping), formatter: component.distanceFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .y:
                FloatSelector(value: $component.cartesian.y, scale: editingParamBinding(keyPath: \.y.scale), isSnappingEnabled: editingParamBinding(keyPath: \.y.isSnapping), formatter: component.distanceFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .z:
                FloatSelector(value: $component.cartesian.z, scale: editingParamBinding(keyPath: \.z.scale), isSnappingEnabled: editingParamBinding(keyPath: \.z.isSnapping), formatter: component.distanceFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            }
        }
        .tint(Color(uiColor: component.objectSelectionColor))
        .transition(.identity)
    }
    
    func editingParamBinding<T>(keyPath: WritableKeyPath<ObjectPropertyCartesianPositionEditingParams, T>) -> Binding<T> {
        _editingParams.projectedValue[dynamicMember: component.editingParamsKeyPath.appending(path: keyPath)]
    }
    
}
