//
//  TransformationComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import SwiftUI


class TransformationComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    lazy private(set) var position = PositionComponent(object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var orientation = OrientationComponent(object: self.object, parent: self)
    lazy private(set) var scale = ScaleComponent(object: self.object, parent: self)
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(title: "Transformation", parent: parent)
    }
    
    override var subcomponents: [Component]? { [position, orientation, scale] }
    
}


struct TransformationComponentView: View {
    
    @ObservedObject var component: TransformationComponent
    @Binding var editedComponent: Component?
    
    var body: some View {
        Form {
            PositionComponentView(component: component.position, editedComponent: $editedComponent)
            Section(ScaleComponent.title) {
                ScaleComponentView(component: component.scale, editedComponent: $editedComponent)
            }
            Section(OrientationComponent.title) {
                OrientationComponentView(component: component.orientation, editedComponent: $editedComponent)
            }
        }
    }
    
}

