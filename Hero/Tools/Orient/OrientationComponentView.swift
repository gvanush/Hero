//
//  OrientationComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.01.23.
//

import SwiftUI
import Combine


class OrientationComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var variantCancellable: AnyCancellable?
    private var originPointObject: SPTObject
    private var positionSubscription: SPTAnySubscription?
    
    @SPTObservedComponent private var orientation: SPTOrientation
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        
        _orientation = .init(object: object)
        
        super.init(parent: parent)
        
        _orientation.publisher = self.objectWillChange
        
        SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
        
        positionSubscription = SPTOrientation.onDidChangeSink(object: object) { [unowned self] oldValue in
            if oldValue.model != orientationModel {
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
    
    var orientationModel: SPTOrientationModel {
        get {
            orientation.model
        }
        set {
            
            guard orientationModel != newValue else {
                return
            }
            
            switch newValue {
            case .eulerXYZ:
                orientation = orientation.toEulerXYZ
            case .eulerXZY:
                orientation = orientation.toEulerXZY
            case .eulerYXZ:
                orientation = orientation.toEulerYXZ
            case .eulerYZX:
                orientation = orientation.toEulerYZX
            case .eulerZXY:
                orientation = orientation.toEulerZXY
            case .eulerZYX:
                orientation = orientation.toEulerZYX
            case .pointAtDirection:
                // TODO
                fatalError()
                /*var axis = SPTAxis.X
                switch orientationModel {
                case .eulerXYZ, .eulerXZY:
                    break
                case .eulerYXZ, .eulerYZX:
                    axis = .Y
                case .eulerZXY, .eulerZYX:
                    axis = .Z
                case .pointAtDirection:
                    axis = orientation.pointAtDirection.axis
                default:
                    // TODO
                    fatalError()
                }
                orientation = orientation.toPointAtDirection(axis: axis, directionLength: 5.0)*/
                
            default:
                fatalError()
            }
        }
    }
    
    override var title: String {
        "Position"
    }
    
    private func setupVariant() {
        self.variantTag = orientationModel.rawValue
        switch orientationModel {
        case .eulerXYZ, .eulerXZY, .eulerYXZ, .eulerYZX, .eulerZXY, .eulerZYX:
            activeComponent = EulerOrientationComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .pointAtDirection:
            activeComponent = PointAtDirectionComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        default:
            // TODO
            fatalError()
        }
        variantCancellable = activeComponent.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
}

struct OrientationComponentView<RC>: View {
    
    @ObservedObject var component: OrientationComponent
    let viewProvider: ComponentViewProvider<RC>
    
    @EnvironmentObject var actionBarModel: ActionBarModel
    
    var body: some View {
        component.activeComponent.accept(viewProvider)
            .actionBarObjectSection {
                ActionBarMenu(title: "Orientation Model", iconName: "slider.horizontal.3", selected: $component.orientationModel)
                    .tag(component.id)
            }
    }
    
}
