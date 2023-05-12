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
            
            twinObject = sceneViewModel.scene.makeObject()
            SPTPosition.make(SPTPosition.get(object: object), object: twinObject)
            SPTScale.make(SPTScale.get(object: object), object: twinObject)
            SPTOrientation.make(SPTOrientation.get(object: object), object: twinObject)
            
            var meshLook = SPTMeshLook.get(object: object)
            meshLook.categories &= ~LookCategories.renderableModel.rawValue
            SPTMeshLook.update(meshLook, object: object)
            
            meshLook.categories = LookCategories.guide.rawValue
            SPTMeshLook.make(meshLook, object: twinObject)
            
            if var outlineLook = SPTOutlineLook.tryGet(object: object) {
                SPTOutlineLook.make(outlineLook, object: twinObject)
                
                outlineLook.categories &= ~LookCategories.guide.rawValue
                SPTOutlineLook.update(outlineLook, object: object)
            }
            
        }
        .onDisappear {
            model[object] = nil
            SPTSceneProxy.destroyObject(originPointObject)
            
            var meshLook = SPTMeshLook.get(object: object)
            meshLook.categories |= LookCategories.renderableModel.rawValue
            SPTMeshLook.update(meshLook, object: object)
            
            if var outlineLook = SPTOutlineLook.tryGet(object: object) {
                outlineLook.categories |= LookCategories.guide.rawValue
                SPTOutlineLook.update(outlineLook, object: object)
            }
            
            SPTSceneProxy.destroyObject(twinObject)
        }
    }
    
}


struct AnimateOrientationToolView: View {
    
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
