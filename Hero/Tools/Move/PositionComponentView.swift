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
    
    private var coordinateSystemSubscription: SPTAnySubscription?
    private var variantCancellable: AnyCancellable?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(parent: parent)
        
        coordinateSystemSubscription = SPTPosition.onDidChangeSink(object: object) { [unowned self] oldValue in
            if oldValue.coordinateSystem != coordinateSystem {
                self.setupVariant()
            }
        }
        
        setupVariant()
        
    }
    
    var coordinateSystem: SPTCoordinateSystem {
        get {
            SPTPosition.get(object: object).coordinateSystem
        }
        set {
            var position = SPTPosition.get(object: object)
            
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
            
            SPTPosition.update(position, object: object)
        }
    }
    
    override var title: String {
        "Position"
    }
    
    private func setupVariant() {
        switch coordinateSystem {
        case .cartesian:
            activeComponent = CartesianPositionComponent(title: "Position", editingParamsKeyPath: \.[cartesianPositionOf: object], object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .linear:
            activeComponent = LinearPositionComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .spherical:
            // TODO
            break
        case .cylindrical:
            // TODO
            break
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
                ActionBarMenu(iconName: "slider.vertical.3", selected: $component.coordinateSystem)
                    .tag(component.id)
            }
            .onAppear {
                actionBarModel.scrollToObjectSection()
            }
    }
    
}
