//
//  MeshInspector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.08.22.
//

import SwiftUI

class MeshObjectInspectorModel: ObservableObject {
    
    let object: SPTObject
    @SPTObservedOptionalAnimatorBinding<SPTAnimatableObjectProperty> var positionXAnimatorBinding: SPTAnimatorBinding?
    @SPTObservedOptionalAnimatorBinding<SPTAnimatableObjectProperty> var positionYAnimatorBinding: SPTAnimatorBinding?
    @SPTObservedOptionalAnimatorBinding<SPTAnimatableObjectProperty> var positionZAnimatorBinding: SPTAnimatorBinding?
    
    init(object: SPTObject) {
        self.object = object
        
        _positionXAnimatorBinding = .init(property: .positionX, object: object)
        _positionYAnimatorBinding = .init(property: .positionY, object: object)
        _positionZAnimatorBinding = .init(property: .positionZ, object: object)
        
        _positionXAnimatorBinding.publisher = self.objectWillChange
        _positionYAnimatorBinding.publisher = self.objectWillChange
        _positionZAnimatorBinding.publisher = self.objectWillChange
    }
    
    var objectName: String {
        SPTMetadataGet(object).name
    }
    
    let positionFormatter = FloatSelector.defaultNumberFormatter(scale: ._1)
    
    var position: SPTPosition {
        SPTPosition.get(object: object)
    }
    
    let scaleFormatter = FloatSelector.defaultNumberFormatter(scale: ._10)
    
    var scale: SPTScale {
        SPTScale.get(object: object)
    }
    
    let rotationFormatter = MeasurementFormatter.angleFormatter
    let rotationSubjectProvider = MeasurementFormatter.angleSubjectProvider
    
    var orientation: SPTOrientation {
        SPTOrientation.get(object: object)
    }
    
    func bindAnimator(id: SPTAnimatorId, property: SPTAnimatableObjectProperty) {
        let binding = SPTAnimatorBinding(animatorId: id, valueAt0: -10.0, valueAt1: 10.0)
        property.bind(binding, object: object)
    }
    
    func getAnimator(id: SPTAnimatorId) -> SPTAnimator {
        SPTAnimator.get(id: id)
    }
}

struct MeshObjectInspector: View {
    
    @StateObject var model: MeshObjectInspectorModel
    @EnvironmentObject private var rootViewModel: RootViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var animatorSelectorItem: SPTAnimatableObjectProperty?
    
    var body: some View {
        NavigationStack {
            Form {
                positionView()
                positionAnimationView()
                orientationView()
                scaleView()
            }
            // NOTE: This is necessary for unknown reason to prevent 'Form' row
            // from being selectable when there is a button inside.
            .buttonStyle(BorderlessButtonStyle())
            .navigationTitle(model.objectName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(item: $animatorSelectorItem, content: { property in
            AnimatorSelector { animatorId in
                if let animatorId = animatorId {
                    model.bindAnimator(id: animatorId, property: property)
                }
                animatorSelectorItem = nil
            }
        })
        
    }
    
    func positionView() -> some View {
        Section("Position") {
            SceneEditableParam(title: "X", valueText: Text(NSNumber(value: model.position.xyz.x), formatter: model.positionFormatter), editAction: { self.onEditPosition(axis: .x) })
            SceneEditableParam(title: "Y", valueText: Text(NSNumber(value: model.position.xyz.y), formatter: model.positionFormatter), editAction: { self.onEditPosition(axis: .y) })
            SceneEditableParam(title: "Z", valueText: Text(NSNumber(value: model.position.xyz.z), formatter: model.positionFormatter), editAction: { self.onEditPosition(axis: .z) })
        }
    }
    
    func onEditPosition(axis: Axis) {
        rootViewModel.activeToolViewModel = rootViewModel.moveToolViewModel
        rootViewModel.moveToolViewModel.selectedObjectViewModel!.axis = axis
        presentationMode.wrappedValue.dismiss()
    }
    
    func positionAnimationView() -> some View {
        Section("Position Animation") {
            itemViewFor(model.positionXAnimatorBinding, title: "X Binding", property: .positionX) { onEditPositionAnimatorBinding(property: .positionX) }
            itemViewFor(model.positionYAnimatorBinding, title: "Y Binding", property: .positionY) { onEditPositionAnimatorBinding(property: .positionY) }
            itemViewFor(model.positionZAnimatorBinding, title: "Z Binding", property: .positionZ) { onEditPositionAnimatorBinding(property: .positionZ) }
        }
    }
    
    func onEditPositionAnimatorBinding(property: SPTAnimatableObjectProperty) {
        rootViewModel.activeToolViewModel = rootViewModel.animatePositionToolView
        let selectedObjectVM = rootViewModel.animatePositionToolView.selectedObjectViewModel!
        switch property {
        case .positionX:
            selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.x
        case .positionY:
            selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.y
        case .positionZ:
            selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.z
        @unknown default:
            assert(false)
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func orientationView() -> some View {
        Section("Orientation") {
            SceneEditableParam(title: "X", valueText: Text(model.rotationSubjectProvider(model.orientation.euler.rotation.x), formatter: model.rotationFormatter), editAction: { self.onEditOrientation(axis: .x) })
            SceneEditableParam(title: "Y", valueText: Text(model.rotationSubjectProvider(model.orientation.euler.rotation.y), formatter: model.rotationFormatter), editAction: { self.onEditOrientation(axis: .y) })
            SceneEditableParam(title: "Z", valueText: Text(model.rotationSubjectProvider(model.orientation.euler.rotation.z), formatter: model.rotationFormatter), editAction: { self.onEditOrientation(axis: .z) })
        }
    }
    
    func onEditOrientation(axis: Axis) {
        rootViewModel.activeToolViewModel = rootViewModel.orientToolViewModel
        rootViewModel.orientToolViewModel.selectedObjectViewModel!.axis = axis
        presentationMode.wrappedValue.dismiss()
    }
    
    func scaleView() -> some View {
        Section("Scale") {
            SceneEditableParam(title: "X", valueText: Text(NSNumber(value: model.scale.xyz.x), formatter: model.scaleFormatter), editAction: { self.onEditScale(axis: .x) })
            SceneEditableParam(title: "Y", valueText: Text(NSNumber(value: model.scale.xyz.y), formatter: model.scaleFormatter), editAction: { self.onEditScale(axis: .y) })
            SceneEditableParam(title: "Z", valueText: Text(NSNumber(value: model.scale.xyz.z), formatter: model.scaleFormatter), editAction: { self.onEditScale(axis: .z) })
        }
    }
    
    func onEditScale(axis: Axis) {
        rootViewModel.activeToolViewModel = rootViewModel.scaleToolViewModel
        rootViewModel.scaleToolViewModel.selectedObjectViewModel!.axis = axis
        presentationMode.wrappedValue.dismiss()
    }
    
    @ViewBuilder
    func itemViewFor(_ animatorBinding: SPTAnimatorBinding?, title: String, property: SPTAnimatableObjectProperty, onEdit: @escaping () -> Void) -> some View {
        LabeledContent(title) {
            if let animatorBinding = animatorBinding {
                Text(model.getAnimator(id: animatorBinding.animatorId).name)
            }
            Button {
                if animatorBinding == nil {
                    animatorSelectorItem = property
                } else {
                    onEdit()
                }
            } label: {
                Image(systemName: animatorBinding == nil ? "minus" : "slider.horizontal.below.rectangle")
                    .imageScale(.large)
            }
        }
    }
}


struct MeshObjectInspector_Previews: PreviewProvider {
    
    static let sceneViewModel = SceneViewModel()
    
    static var previews: some View {
        
        let factory = ObjectFactory(scene: sceneViewModel.scene)
        let object = factory.makeMesh(meshId: MeshRegistry.standard.meshRecords.first!.id)
        sceneViewModel.selectedObject = object
        
        return MeshObjectInspector(model: .init(object: object))
            .environmentObject(RootViewModel(sceneViewModel: Self.sceneViewModel))
    }
}
