//
//  GeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI

class GeneratorComponent: Component {
    
    let generator: SPTObject
    lazy private(set) var transformation = TransformationComponent(parent: self)
    @Published private var sourceMeshRecord: MeshRecord
    
    init(generator: SPTObject, sourceMeshRecord: MeshRecord) {
        self.generator = generator
        self.sourceMeshRecord = sourceMeshRecord
        super.init(title: "Generator", parent: nil)
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
    
    override var subcomponents: [Component]? { [transformation] }
}


struct GeneratorView: View {
    
    @ObservedObject var generatorComponent: GeneratorComponent
    @State private var editedComponent: Component?
    @State private var showsTemplateObjectSelector = false
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var body: some View {
        Form {
            Section {
                sourceObjectRow
                SceneEditableParam(title: "Quantity", value: "10") {
                    // TODO
                }
                SceneEditableCompositeParam(title: generatorComponent.transformation.title, value: nil) {
                    editedComponent = generatorComponent.transformation
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
        .sheet(isPresented: $showsTemplateObjectSelector, onDismiss: {}, content: {
            TemplateObjectSelector { meshRecord in
                generatorComponent.updateSourceMeshRecord(meshRecord)
            }
        })
        .fullScreenCover(item: $editedComponent, onDismiss: {}, content: { editedComponent in
            EditGeneratorView(activeComponent: editedComponent)
                .environmentObject(generatorComponent)
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
                    Image(systemName: generatorComponent.sourceObjectIconName)
                    Text(generatorComponent.sourceObjectTypeName)
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
        NavigationView {
            GeneratorView(generatorComponent: GeneratorComponent(generator: kSPTNullObject, sourceMeshRecord: MeshRecord(name: "cone", iconName: "cone", id: 0)))
                .environmentObject(SceneViewModel())
                .navigationBarHidden(true)
        }
    }
}
