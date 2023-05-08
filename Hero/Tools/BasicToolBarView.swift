//
//  BasicToolBarView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


fileprivate struct SelectedObjectBarView: View {
    
    let object: SPTObject
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    init(object: SPTObject) {
        self.object = object
    }
    
    var body: some View {
        HStack {
            Divider()
            BasicToolNavigationView(tool: .move, object: object)
            if let namespace = model[object].disclosedElementsData?.last?.namespace {
                Color.clear
                    .frame(width: 46.0)
                    .matchedGeometryEffect(id: elementOptionsViewMatchedGeometryID, in: namespace, properties: .position)
            }
        }
    }
    
}


struct BasicToolBarView: View {
    
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectBarView(object: object)
                .transition(.identity)
                .id(object)
                .environmentObject(model)
        }
    }
    
}
