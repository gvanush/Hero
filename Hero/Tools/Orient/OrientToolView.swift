//
//  OrientToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI


fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @StateObject private var orientation: SPTObservableComponent<SPTOrientation>
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originPointObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
        _orientation = .init(wrappedValue: .init(object: object))
    }
    
    var body: some View {
        VStack {
            BasicToolElementActionViewPlaceholder(object: object)
            
            ElementTreeView(activeIndexPath: $editingParams[tool: .orient, object].activeElementIndexPath) {
                EulerOrientationElement(object: object, model: orientation.model)
            }
        }
        .onPreferenceChange(DisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onAppear {
            originPointObject = sceneViewModel.scene.makeObject()
            SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
            SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
        }
        .onDisappear {
            model[object] = nil
            SPTSceneProxy.destroyObject(originPointObject)
        }
    }
    
}


struct OrientToolView: View {
    
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
