//
//  ShadeToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import SwiftUI
import Combine


fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @StateObject private var position: SPTObservableComponent<SPTPosition>
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    init(object: SPTObject) {
        self.object = object
        _position = .init(wrappedValue: .init(object: object))
    }
    
    var body: some View {
        VStack {
            
            BasicToolElementActionViewPlaceholder(object: object)
            
            ElementTreeView(activeIndexPath: $editingParams[tool: .shade, object].activeElementIndexPath) {
                ShadeElement(object: object)
            }
        }
        .onPreferenceChange(DisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onDisappear {
            model[object] = nil
        }
    }
    
}


struct ShadeToolView: View {
    
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
