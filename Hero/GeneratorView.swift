//
//  GeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI

class GeneratorViewModel: ObservableObject {
    
    private let meshRecord: MeshRecord
    
    var sourceObjectTypeName: String {
        meshRecord.name.capitalizingFirstLetter()
    }
    
    var sourceObjectIconName: String {
        meshRecord.iconName
    }
    
    init(meshRecord: MeshRecord) {
        self.meshRecord = meshRecord
    }
}


struct GeneratorView: View {
    
    @State private var isViewingObject = false
    @State private var isNavigating = false
    @ObservedObject var model: GeneratorViewModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack {
                NavigationView {
                    Form {
                        Section {
                            sourceObjectRow
                            SceneEditableParam(title: "Quantity", value: "10") {
                                // TODO
                            }
                            SceneEditableCompositeParam(title: "Transformation", value: nil) {
                                // TODO
                            } destionation: {
                                Color.red
                            }
                        }
                        Section("Arrangement") {
                            ForEach(1..<30) { _ in
                                Text("dummy")
                            }
                        }
                    }
                    // NOTE: This is necessary for unknown reason to prevent Form row
                    // from being selectable when there is a button inside.
                    .buttonStyle(BorderlessButtonStyle())
                    .navigationTitle("New Generator")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(isNavigating)
                    .navigationViewStyle(.stack)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
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
                    .safeAreaInset(edge: .bottom) {
                        Color.clear
                            .frame(width: FloatingSceneView.closedStateWidth, height: FloatingSceneView.closedStateHeight)
                    }
                }
                
                FloatingSceneView()

            }
        }
    }
    
    var sourceObjectRow: some View {
        HStack {
            Text("Source")
            Spacer()
            Button {
                // TODO:
            } label: {
                HStack {
                    Image(systemName: model.sourceObjectIconName)
                    Text(model.sourceObjectTypeName)
                }
            }
        }
    }
}


struct SceneEditableParam: View {
    
    let title: String
    let value: String?
    let editAction: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
            Button(action: editAction) {
                Image(systemName: "slider.horizontal.below.rectangle")
            }
        }
    }
}


struct SceneEditableCompositeParam<Destination>: View where Destination: View {
    
    let title: String
    let value: String?
    let editAction: () -> Void
    let destionation: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destionation) {
            Text(title)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
            Button(action: editAction) {
                Image(systemName: "slider.horizontal.below.rectangle")
            }
        }
    }
}


struct GeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratorView(model: GeneratorViewModel(meshRecord: MeshRecord(name: "cone", iconName: "cone", id: 0)))
            .environmentObject(SceneViewModel())
    }
}
