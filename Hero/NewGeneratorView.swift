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
    @State private var generatorViewModel: GeneratorViewModel? = nil
    @State private var isEditing = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    Group {
                        if let generatorViewModel = generatorViewModel {
                            GeneratorView(model: generatorViewModel, isEditing: $isEditing)
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
                    .safeAreaInset(edge: .bottom) {
                        Color.clear
                            .frame(size: floatingSceneClosedStateSize(geometry: geometry))
                    }
                }
                FloatingSceneView(closedStateSize: floatingSceneClosedStateSize(geometry: geometry), isRenderingPaused: showsTemplateObjectSelector || isEditing)
            }
            .sheet(isPresented: $showsTemplateObjectSelector, onDismiss: {
                if generatorViewModel == nil {
                    presentationMode.wrappedValue.dismiss()
                }
            }, content: {
                TemplateObjectSelector { meshRecord in
                    let generator = sceneViewModel.scene.makeObject()
                    SPTMakeGenerator(generator, meshRecord.id, 10)
                    generatorViewModel = GeneratorViewModel(generator: generator, sourceMeshRecord: meshRecord)
                }
            })
        }
    }
    
    func floatingSceneClosedStateSize(geometry: GeometryProxy) -> CGSize {
        let width = Self.floatingSceneViewClosedStateWidthFactor * (geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing)
        let fullWidth = geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing
        let fullHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
        return CGSize(width: width, height: (fullHeight / fullWidth) * width)
    }
    
    static let floatingSceneViewClosedStateWidthFactor: CGFloat = 0.25
    
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
