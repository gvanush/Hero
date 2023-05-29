//
//  AnimateOrientationToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.23.
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
                
                ElementTreeView(activeIndexPath: $editingParams[tool: .animateOrientation, object].activeElementIndexPath) {
                    
                    switch SPTOrientation.get(object: object).model {
                    case .eulerXYZ:
                        EulerOrientationAnimatorBindingsElement(object: object, twinObject: twinObject)
                    case .eulerXZY:
                        EulerOrientationAnimatorBindingsElement(object: object, twinObject: twinObject)
                    case .eulerYXZ:
                        EulerOrientationAnimatorBindingsElement(object: object, twinObject: twinObject)
                    case .eulerYZX:
                        EulerOrientationAnimatorBindingsElement(object: object, twinObject: twinObject)
                    case .eulerZXY:
                        EulerOrientationAnimatorBindingsElement(object: object, twinObject: twinObject)
                    case .eulerZYX:
                        EulerOrientationAnimatorBindingsElement(object: object, twinObject: twinObject)
                    default:
                        fatalError()
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


struct AnimateOrientationToolView: View {
    
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
