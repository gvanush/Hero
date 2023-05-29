//
//  AnimateShadeToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.11.22.
//

import SwiftUI
import Combine

fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var twinObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
    }
    
    var body: some View {
        VStack {
            
            if let twinObject {
                BasicToolElementActionViewPlaceholder(object: object)
                
                ElementTreeView(activeIndexPath: $editingParams[tool: .animateShade, object].activeElementIndexPath) {
                    ShadeAnimatorBindingsElement(object: object, twinObject: twinObject)
                }
            }
        }
        .onPreferenceChange(DisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onAppear {
            twinObject = sceneViewModel.makeTwin(object: object)
        }
        .onDisappear {
            model[object] = nil
            sceneViewModel.destroyTwin(twinObject, object: object)
        }
    }
    
}

struct AnimateShadeToolView: View {
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
