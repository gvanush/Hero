//
//  NewGeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI


struct NewGeneratorView: View {
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showsTemplateObjectSelector = true
    @State private var generatorComponent: GeneratorComponent? = nil
    
    var body: some View {
        NavigationView {
            Group {
                if let generatorComponent = generatorComponent {
                    GeneratorView(generatorComponent: generatorComponent)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    SPTScene.destroy(generatorComponent.object)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text("Done")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                } else {
                    Color.clear
                }
            }
            .navigationTitle("New Generator")
        }
        .sheet(isPresented: $showsTemplateObjectSelector, onDismiss: {
            if generatorComponent == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }, content: {
            TemplateObjectSelector { meshId in
                let generatorObject = sceneViewModel.scene.makeObject()
                SPTMakeGenerator(generatorObject, meshId, 5)
                generatorComponent = GeneratorComponent(object: generatorObject)
            }
        })
    }
    
}


struct NewGeneratorView_Previews: PreviewProvider {
    
    static var previews: some View {
        let data = SampleSceneData()
        return NewGeneratorView()
            .environmentObject(data.sceneViewModel)
    }
}
