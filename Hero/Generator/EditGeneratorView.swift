//
//  EditGeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.01.22.
//

import SwiftUI

struct EditGeneratorView: View {
    
    @State private var activeComponent: Component
    @State private var isNavigating = false
    @EnvironmentObject var generatorComponent: GeneratorComponent
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(activeComponent: Component) {
        _activeComponent = State<Component>(initialValue: activeComponent)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation))
                    .ignoresSafeArea()
                ComponentTreeNavigationView(rootComponent: generatorComponent, activeComponent: $activeComponent)
                    .visible(!isNavigating)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // TODO:
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
            .navigationBarHidden(isNavigating)
            .navigationTitle("Edit Generator")
        }
    }
    
}

struct EditGeneratorView_Previews: PreviewProvider {
    
    struct ContainerView: View {
        
        @StateObject var sceneViewModel: SceneViewModel
        @StateObject var generatorComponent: GeneratorComponent
        
        var body: some View {
            Group {
                EditGeneratorView(activeComponent: generatorComponent.transformation)
                    .environmentObject(sceneViewModel)
                    .environmentObject(generatorComponent)
            }
        }
    }
    
    static var previews: some View {
        
        let sceneViewModel = SceneViewModel()
        let generatorObject = sceneViewModel.scene.makeObject()
        
        SPTMakeGenerator(generatorObject, MeshRegistry.standard.recordNamed("cone")!.id, 10)
        let generatorComponent = GeneratorComponent(object: generatorObject)
        
        return ContainerView(sceneViewModel: sceneViewModel, generatorComponent: generatorComponent)
    }
}
