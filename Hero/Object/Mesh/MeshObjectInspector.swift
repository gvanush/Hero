//
//  MeshInspector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.08.22.
//

import SwiftUI

class MeshObjectInspectorModel: ObservableObject {
    
    let object: SPTObject
    let rootViewModel: RootViewModel
    
    @SPTObservedOptionalAnimatorBinding<SPTAnimatableObjectProperty> fileprivate var positionXAnimatorBinding: SPTAnimatorBinding?
    @SPTObservedOptionalAnimatorBinding<SPTAnimatableObjectProperty> fileprivate var positionYAnimatorBinding: SPTAnimatorBinding?
    @SPTObservedOptionalAnimatorBinding<SPTAnimatableObjectProperty> fileprivate var positionZAnimatorBinding: SPTAnimatorBinding?
    
    init(object: SPTObject, rootViewModel: RootViewModel) {
        self.object = object
        self.rootViewModel = rootViewModel
        
        _positionXAnimatorBinding = .init(property: .cartesianPositionX, object: object)
        _positionYAnimatorBinding = .init(property: .cartesianPositionY, object: object)
        _positionZAnimatorBinding = .init(property: .cartesianPositionZ, object: object)
        
        _shading = .init(object: object, keyPath: \.shading)
        
        _positionXAnimatorBinding.publisher = self.objectWillChange
        _positionYAnimatorBinding.publisher = self.objectWillChange
        _positionZAnimatorBinding.publisher = self.objectWillChange
        
        _shading.publisher = self.objectWillChange
    }
    
    var objectName: String {
        SPTMetadataGet(object).name
    }
    
    // MARK: Position
    let distanceFormatter = Formatters.distance
    
    var position: SPTPosition {
        SPTPosition.get(object: object)
    }
    
    func editPosition(axis: Axis, dismiss: DismissAction) {
//        rootViewModel.activeToolViewModel = rootViewModel.moveToolViewModel
        // TODO
//        rootViewModel.moveToolViewModel.selectedObjectViewModel!.axis = axis
        dismiss()
    }
    
    // MARK: Scale
    let scaleFormatter = Formatters.scale
    
    var scale: SPTScale {
        SPTScale.get(object: object)
    }
    
    func editScale(axis: Axis, dismiss: DismissAction) {
        rootViewModel.activeToolViewModel = rootViewModel.scaleToolViewModel
        // TODO
//        rootViewModel.scaleToolViewModel.selectedObjectViewModel!.axis = axis
        dismiss()
    }
    
    // MARK: Orientation
    let rotationFormatter = AngleFormatter()
    
    var orientation: SPTOrientation {
        SPTOrientation.get(object: object)
    }
    
    func editOrientation(axis: Axis, dismiss: DismissAction) {
        // TODO
//        rootViewModel.activeToolViewModel = rootViewModel.orientToolViewModel
//        rootViewModel.orientToolViewModel.selectedObjectViewModel!.axis = axis
        dismiss()
    }
    
    // MARK: Position Animator
    func bindAnimator(id: SPTAnimatorId, property: SPTAnimatableObjectProperty) {
        let binding = SPTAnimatorBinding(animatorId: id, valueAt0: -10.0, valueAt1: 10.0)
        property.bind(binding, object: object)
    }
    
    func getAnimator(id: SPTAnimatorId) -> SPTAnimator {
        SPTAnimator.get(id: id)
    }
    
    func editPositionAnimatorBinding(property: SPTAnimatableObjectProperty, dismiss: DismissAction) {
        rootViewModel.activeToolViewModel = rootViewModel.animatePositionToolViewModel
        // TODO
//        let selectedObjectVM = rootViewModel.animatePositionToolViewModel.selectedObjectViewModel!
//        switch property {
//        case .cartesianPositionX:
//            selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.x
//        case .cartesianPositionY:
//            selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.y
//        case .cartesianPositionZ:
//            selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.z
//        default:
//            fatalError()
//        }
        dismiss()
    }
    
    // MARK: Shading
    let shininessFormatter = Formatters.shininess
    let colorChannelFormatter = Formatters.colorChannel
    
    @SPTListenedComponentProperty<SPTMeshLook, SPTMeshShading> var shading: SPTMeshShading
    
    var colorModel: SPTColorModel {
        get {
            shading.blinnPhong.color.model
        }
        set {
            switch newValue {
            case .RGB:
                shading.blinnPhong.color = shading.blinnPhong.color.toRGBA
            case .HSB:
                shading.blinnPhong.color = shading.blinnPhong.color.toHSBA
            }
        }
    }
    
    func editShading(property: ShadeComponent.Property, dismiss: DismissAction) {
        rootViewModel.activeToolViewModel = rootViewModel.shadeToolViewModel
        let selectedObjectVM = rootViewModel.shadeToolViewModel.selectedObjectViewModel!
        selectedObjectVM.activeComponent = selectedObjectVM.rootComponent
        selectedObjectVM.rootComponent.selectedProperty = .shininess
        dismiss()
    }
    
    func editHSBColor(channel: HSBColorChannel, dismiss: DismissAction) {
        rootViewModel.activeToolViewModel = rootViewModel.shadeToolViewModel
        let selectedObjectVM = rootViewModel.shadeToolViewModel.selectedObjectViewModel!
        selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.color
        selectedObjectVM.rootComponent.color.selectedPropertyIndex = channel.rawValue
        dismiss()
    }
    
    func editRGBColor(channel: RGBColorChannel, dismiss: DismissAction) {
        rootViewModel.activeToolViewModel = rootViewModel.shadeToolViewModel
        let selectedObjectVM = rootViewModel.shadeToolViewModel.selectedObjectViewModel!
        selectedObjectVM.activeComponent = selectedObjectVM.rootComponent.color
        selectedObjectVM.rootComponent.color.selectedPropertyIndex = channel.rawValue
        dismiss()
    }
}

struct MeshObjectInspector: View {
    
    @StateObject var model: MeshObjectInspectorModel
    @EnvironmentObject private var rootViewModel: RootViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var animatorSelectorItem: SPTAnimatableObjectProperty?
    
    var body: some View {
        NavigationStack {
            Form {
                positionView()
                positionAnimationView()
                orientationView()
                scaleView()
                shadeView()
                emptySection
                emptySection
                emptySection
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
            SceneEditableParam(title: "X", valueText: textFor(model.position.cartesian.x, formatter: model.distanceFormatter), editAction: { model.editPosition(axis: .x, dismiss: dismiss) })
            SceneEditableParam(title: "Y", valueText: textFor(model.position.cartesian.y, formatter: model.distanceFormatter), editAction: { model.editPosition(axis: .y, dismiss: dismiss) })
            SceneEditableParam(title: "Z", valueText: textFor(model.position.cartesian.z, formatter: model.distanceFormatter), editAction: { model.editPosition(axis: .z, dismiss: dismiss) })
        }
    }
    
    func positionAnimationView() -> some View {
        Section("Position Animation") {
            itemViewFor(model.positionXAnimatorBinding, title: "X Binding", property: .cartesianPositionX) { model.editPositionAnimatorBinding(property: .cartesianPositionX, dismiss: dismiss) }
            itemViewFor(model.positionYAnimatorBinding, title: "Y Binding", property: .cartesianPositionY) { model.editPositionAnimatorBinding(property: .cartesianPositionY, dismiss: dismiss) }
            itemViewFor(model.positionZAnimatorBinding, title: "Z Binding", property: .cartesianPositionZ) { model.editPositionAnimatorBinding(property: .cartesianPositionZ, dismiss: dismiss) }
        }
    }
    
    func orientationView() -> some View {
        Section("Orientation") {
            // TODO
            /*SceneEditableParam(title: "X", valueText: textFor(model.orientation.euler.rotation.x, formatter: model.rotationFormatter), editAction: { model.editOrientation(axis: .x, dismiss: dismiss) })
            SceneEditableParam(title: "Y", valueText: textFor(model.orientation.euler.rotation.y, formatter: model.rotationFormatter), editAction: { model.editOrientation(axis: .y, dismiss: dismiss) })
            SceneEditableParam(title: "Z", valueText: textFor(model.orientation.euler.rotation.z, formatter: model.rotationFormatter), editAction: { model.editOrientation(axis: .z, dismiss: dismiss) })*/
        }
    }
    
    func scaleView() -> some View {
        Section("Scale") {
            SceneEditableParam(title: "X", valueText: textFor(model.scale.xyz.x, formatter: model.scaleFormatter), editAction: { model.editScale(axis: .x, dismiss: dismiss) })
            SceneEditableParam(title: "Y", valueText: textFor(model.scale.xyz.y, formatter: model.scaleFormatter), editAction: { model.editScale(axis: .y, dismiss: dismiss) })
            SceneEditableParam(title: "Z", valueText: textFor(model.scale.xyz.z, formatter: model.scaleFormatter), editAction: { model.editScale(axis: .z, dismiss: dismiss) })
        }
    }
    
    func shadeView() -> some View {
        Section("Shade") {
            SceneEditableParam(title: "Shininess", valueText: textFor(model.shading.blinnPhong.shininess, formatter: model.shininessFormatter), editAction: {
                model.editShading(property: .shininess, dismiss: dismiss)
            })
            DisclosureGroup("Color") {
                MultiVariantParam(title: "Model", editIconName: "camera.filters", selected: $model.colorModel)
                
                switch model.shading.blinnPhong.color.model {
                case .HSB:
                    SceneEditableParam(title: "Hue", valueText: textFor(model.shading.blinnPhong.color.hsba.hue, formatter: model.colorChannelFormatter), editAction: { model.editHSBColor(channel: .hue, dismiss: dismiss) })
                    SceneEditableParam(title: "Saturation", valueText: textFor(model.shading.blinnPhong.color.hsba.saturation, formatter: model.colorChannelFormatter), editAction: { model.editHSBColor(channel: .saturation, dismiss: dismiss) })
                    SceneEditableParam(title: "Brightness", valueText: textFor(model.shading.blinnPhong.color.hsba.brightness, formatter: model.colorChannelFormatter), editAction: { model.editHSBColor(channel: .brightness, dismiss: dismiss) })
                case .RGB:
                    SceneEditableParam(title: "Red", valueText: textFor(model.shading.blinnPhong.color.rgba.red, formatter: model.colorChannelFormatter), editAction: { model.editRGBColor(channel: .red, dismiss: dismiss) })
                    SceneEditableParam(title: "Green", valueText: textFor(model.shading.blinnPhong.color.rgba.green, formatter: model.colorChannelFormatter), editAction: { model.editRGBColor(channel: .green, dismiss: dismiss) })
                    SceneEditableParam(title: "Blue", valueText: textFor(model.shading.blinnPhong.color.rgba.blue, formatter: model.colorChannelFormatter), editAction: { model.editRGBColor(channel: .blue, dismiss: dismiss) })
                }
            }
        }
    }
    
    func textFor(_ floatValue: Float, formatter: Formatter) -> Text {
        Text(NSNumber(value: floatValue), formatter: formatter)
            .font(.body.monospacedDigit())
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
    
    var emptySection: some View {
        Section {
            EmptyView()
        }
    }
}


struct MeshObjectInspector_Previews: PreviewProvider {
    
    static let sceneViewModel = SceneViewModel()
    
    static var previews: some View {
        
        let factory = ObjectFactory(scene: sceneViewModel.scene)
        let object = factory.makeMesh(meshId: MeshRegistry.standard.meshRecords.first!.id, lookCategories: [.renderableModel, .renderable], position: .zero)
        sceneViewModel.selectedObject = object
        
        return MeshObjectInspector(model: .init(object: object, rootViewModel: RootViewModel(sceneViewModel: Self.sceneViewModel)))
    }
}
