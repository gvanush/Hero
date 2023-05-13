//
//  AnimateScaleToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import SwiftUI

fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originPointObject: SPTObject!
    @State private var twinObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
    }
    
    var body: some View {
        VStack {
            
            if let twinObject {
                BasicToolElementActionViewPlaceholder(object: object)
                
                ElementTreeView(activeIndexPath: $editingParams[tool: .animateScale, object].activeElementIndexPath) {
                    
                    switch SPTScale.get(object: object).model {
                    case .XYZ:
                        XYZScaleAnimatorBindingsElement(object: object, twinObject: twinObject)
                    case .uniform:
                        UniformScaleAnimatorBindingsElement(object: object, twinObject: twinObject)
                    }
                    
                }
            }
        }
        .onPreferenceChange(DisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onAppear {
            originPointObject = sceneViewModel.scene.makeObject()
            SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
            SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
            
            twinObject = sceneViewModel.makeTwin(object: object)
            
        }
        .onDisappear {
            model[object] = nil
            SPTSceneProxy.destroyObject(originPointObject)
            
            sceneViewModel.destroyTwin(twinObject, object: object)
        }
    }
    
}

struct AnimateScaleToolView: View {
    
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectView(object: object)
                .id(object)
                .environmentObject(model)
        }
    }
    
}
