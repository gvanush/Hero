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
    @State private var showsMeshSelector = true
    
    @State var selectedMeshRecord: MeshRecord?
    
    var body: some View {
        Group {
            if let selectedMeshRecord = selectedMeshRecord {
                GeneratorView(model: GeneratorViewModel(meshRecord: selectedMeshRecord))
            } else {
                ZStack {
                    Color(UIColor.systemBackground)
                    VStack {
                        HStack {
                            Text("New Generator")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showsMeshSelector, onDismiss: {
            if selectedMeshRecord == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }, content: {
            MeshSelector(selectedMeshRecord: $selectedMeshRecord)
                .environmentObject(sceneViewModel)
        })
    }
    
    var isObjectSelected: Bool {
        selectedMeshRecord != nil
    }
}


struct MeshSelector: View {
    
    @Binding var selectedMeshRecord: MeshRecord?
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List(sceneViewModel.meshRecords) { record in
                HStack {
                    Image(systemName: record.iconName)
                    Text(record.name.capitalizingFirstLetter())
                    Spacer()
                    Button("Select") {
                        selectedMeshRecord = record
                        presentationMode.wrappedValue.dismiss()
                    }

                }
                .onTapGesture {
                    selectedMeshRecord = record
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Select Source Object")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
