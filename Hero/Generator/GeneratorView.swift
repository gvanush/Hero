//
//  GeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI

class GeneratorViewModel: ObservableObject {
    
    let generator: SPTObject
    @Published private var sourceMeshRecord: MeshRecord
    
    init(generator: SPTObject, sourceMeshRecord: MeshRecord) {
        self.generator = generator
        self.sourceMeshRecord = sourceMeshRecord
    }
    
    var sourceObjectTypeName: String {
        sourceMeshRecord.name.capitalizingFirstLetter()
    }
    
    var sourceObjectIconName: String {
        sourceMeshRecord.iconName
    }
    
    func updateSourceMeshRecord(_ record: MeshRecord) {
        sourceMeshRecord = record
        SPTUpdateGeneratorSourceMesh(generator, record.id)
    }
}


struct GeneratorView: View {
    
    @ObservedObject var model: GeneratorViewModel
    @Binding var isEditing: Bool
    @State private var showsTemplateObjectSelector = false
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    sourceObjectRow
                    SceneEditableParam(title: "Quantity", value: "10") {
                        // TODO
                    }
                    SceneEditableCompositeParam(title: "Transformation", value: nil) {
                        isEditing = true
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
        }
        .sheet(isPresented: $showsTemplateObjectSelector, onDismiss: {}, content: {
            TemplateObjectSelector { meshRecord in
                model.updateSourceMeshRecord(meshRecord)
            }
        })
        .fullScreenCover(isPresented: $isEditing, onDismiss: {}, content: {
            EditGeneratorView()
        })
    }
    
    var sourceObjectRow: some View {
        HStack {
            Text("Source")
            Spacer()
            Button {
                showsTemplateObjectSelector = true
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
                    .imageScale(.large)
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
                    .imageScale(.large)
            }
        }
    }
}


struct GeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratorView(model: GeneratorViewModel(generator: kSPTNullObject, sourceMeshRecord: MeshRecord(name: "cone", iconName: "cone", id: 0)), isEditing: .constant(false))
            .environmentObject(SceneViewModel())
    }
}
