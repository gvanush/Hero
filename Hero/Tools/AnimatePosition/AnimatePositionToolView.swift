//
//  AnimatePositionToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.10.22.
//

import SwiftUI
import Combine


fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @StateObject private var position: SPTObservableComponent<SPTPosition>
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originPointObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
        _position = .init(wrappedValue: .init(object: object))
    }
    
    var body: some View {
        VStack {
            
            BasicToolElementActionViewPlaceholder(object: object)
            
            ElementTreeView(activeIndexPath: $editingParams[tool: .animatePosition, object].activeElementIndexPath) {
                
                switch position.coordinateSystem {
                case .cartesian:
                    CartesianPositionAnimatorBindingsElement(object: object)
                case .linear:
                    LinearPositionAnimatorBindingsElement(object: object)
                case .cylindrical:
                    CylindricalPositionAnimatorBindingsElement(object: object)
                case .spherical:
                    SphericalPositionAnimatorBindingsElement(object: object)
                }
                
            }
        }
        .onPreferenceChange(DisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onChange(of: position.value, perform: { newValue in
            SPTPosition.update(newValue, object: originPointObject)
        })
        .onAppear {
            originPointObject = sceneViewModel.scene.makeObject()
            SPTPosition.make(position.value, object: originPointObject)
            SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
        }
        .onDisappear {
            model[object] = nil
            SPTSceneProxy.destroyObject(originPointObject)
        }
    }
    
}


struct AnimatePositionToolView: View {
    
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var scene: MainScene
    
    var body: some View {
        if let object = scene.selectedObject {
            SelectedObjectView(object: object.sptObject)
                .id(object.id)
                .environmentObject(model)
        }
    }
    
}
