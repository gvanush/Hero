//
//  PositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.11.22.
//

import SwiftUI
import Combine


class PositionComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var variantCancellable: AnyCancellable?
    private var originPointObject: SPTObject
    private var positionSubscription: SPTAnySubscription?
    
    @SPTObservedComponent private var position: SPTPosition
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        
        _position = .init(object: object)
        
        super.init(parent: parent)
        
        SPTPosition.make(position, object: originPointObject)
        positionSubscription = SPTPosition.onDidChangeSink(object: object) { [unowned self] oldValue in
            SPTPosition.update(position, object: self.originPointObject)
            if oldValue.coordinateSystem != coordinateSystem {
                self.setupVariant()
            }
        }
        
        setupVariant()
        
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originPointObject)
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: originPointObject)
    }
    
    var coordinateSystem: SPTCoordinateSystem {
        get {
            position.coordinateSystem
        }
        set {
            
            guard coordinateSystem != newValue else {
                return
            }
            
            switch coordinateSystem {
            case .cartesian:
                SPTAnimatableObjectProperty.cartesianPositionX.unbindAnimatorIfBound(object: object)
                SPTAnimatableObjectProperty.cartesianPositionY.unbindAnimatorIfBound(object: object)
                SPTAnimatableObjectProperty.cartesianPositionZ.unbindAnimatorIfBound(object: object)
            case .linear:
                SPTAnimatableObjectProperty.linearPositionOffset.unbindAnimatorIfBound(object: object)
            case .spherical:
                SPTAnimatableObjectProperty.sphericalPositionLatitude.unbindAnimatorIfBound(object: object)
                SPTAnimatableObjectProperty.sphericalPositionLongitude.unbindAnimatorIfBound(object: object)
                SPTAnimatableObjectProperty.sphericalPositionRadius.unbindAnimatorIfBound(object: object)
            case .cylindrical:
                SPTAnimatableObjectProperty.cylindricalPositionLongitude.unbindAnimatorIfBound(object: object)
                SPTAnimatableObjectProperty.cylindricalPositionRadius.unbindAnimatorIfBound(object: object)
                SPTAnimatableObjectProperty.cylindricalPositionHeight.unbindAnimatorIfBound(object: object)
            }
            
            switch newValue {
            case .cartesian:
                position = position.toCartesian
            case .linear:
                position = position.toLinear(origin: position.origin)
            case .spherical:
                position = position.toSpherical(origin: position.origin)
            case .cylindrical:
                position = position.toCylindrical(origin: position.origin)
            }
        }
    }
    
    override var title: String {
        "Position"
    }
    
    private func setupVariant() {
        self.variantTag = coordinateSystem.rawValue
        switch coordinateSystem {
        case .cartesian:
            activeComponent = CartesianPositionComponent(title: "Position", editingParamsKeyPath: \.[cartesianPositionOf: object], object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .linear:
            activeComponent = LinearPositionComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .spherical:
            activeComponent = SphericalPositionComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .cylindrical:
            activeComponent = CylindricalPositionComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct PositionComponentView<RC>: View {
    
    @ObservedObject var component: PositionComponent
    let viewProvider: ComponentViewProvider<RC>
    
    @EnvironmentObject var actionBarModel: ActionBarModel
    
    var body: some View {
        component.activeComponent.accept(viewProvider)
            .actionBarObjectSection {
                ActionBarMenu(iconName: "slider.horizontal.3", selected: $component.coordinateSystem)
                    .tag(component.id)
            }
            .onAppear {
                actionBarModel.scrollToObjectSection()
            }
    }
    
}
