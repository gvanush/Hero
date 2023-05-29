//
//  BasicToolBarView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


fileprivate struct SelectedObjectBarView: View {
    
    let tool: Tool
    let object: SPTObject
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    init(tool: Tool, object: SPTObject) {
        self.tool = tool
        self.object = object
    }
    
    var body: some View {
        HStack {
            Divider()
            BasicToolNavigationView(tool: tool, object: object)
            if let namespace = model[object].disclosedElementsData?.last?.namespace {
                Color.clear
                    .frame(width: 46.0)
                    .matchedGeometryEffect(id: elementOptionsViewMatchedGeometryID, in: namespace, properties: .position)
            }
        }
    }
    
}


struct BasicToolBarView: View {
    
    let tool: Tool
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var scene: MainScene
    
    init(tool: Tool, model: BasicToolModel) {
        self.tool = tool
        self.model = model
    }
    
    var body: some View {
        if let object = scene.selectedObject {
            SelectedObjectBarView(tool: tool, object: object.sptObject)
                .transition(.identity)
                .id(object.id)
                .environmentObject(model)
        }
    }
    
}
