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
                if let generatorViewModel = generatorComponent {
                    GeneratorView(generatorComponent: generatorViewModel)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    SPTScene.destroy(generatorViewModel.generator)
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
            TemplateObjectSelector { meshRecord in
                let generator = sceneViewModel.scene.makeObject()
                SPTMakeGenerator(generator, meshRecord.id, 10)
                generatorComponent = GeneratorComponent(generator: generator, sourceMeshRecord: meshRecord)
            }
        })
    }
    
}


struct NewGeneratorView_Previews: PreviewProvider {
    
    struct NewGeneratorViewContainer: View {
        
        @State var meshRecord: MeshRecord?
        
        var body: some View {
            NewGeneratorView()
                .environmentObject(SceneViewModel())
        }
    }
    
    static var previews: some View {
        NewGeneratorViewContainer()
    }
}
