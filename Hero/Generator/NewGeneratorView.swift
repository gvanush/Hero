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
    @State private var isCancelled = false
    
    var body: some View {
        NavigationView {
            Group {
                if let generatorComponent = generatorComponent {
                    GeneratorView(generatorComponent: generatorComponent)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    isCancelled = true
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
                let generator = sceneViewModel.objectFactory.makeGenerator(sourceMeshId: meshId)
                generatorComponent = GeneratorComponent(object: generator, sceneViewModel: sceneViewModel)
                sceneViewModel.selectedObject = generator
            }
        })
        .onDisappear {
            // Destruction needs to be done here otherwise object data
            // is accessed by SwiftUI views during the dismissal
            if let generatorComponent = generatorComponent, isCancelled {
                sceneViewModel.selectedObject = nil
                SPTSceneProxy.destroyObject(generatorComponent.object)
            }
        }
    }
    
}


struct NewGeneratorView_Previews: PreviewProvider {
    
    static var previews: some View {
        let data = SampleSceneData()
        return NewGeneratorView()
            .environmentObject(data.sceneViewModel)
    }
}
