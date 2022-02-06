//
//  GeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI

class GeneratorComponent: Component {
    
    let object: SPTObject
    lazy private(set) var transformation = TransformationComponent(parent: self)
    
    init(object: SPTObject) {
        self.object = object
        super.init(title: "Generator", parent: nil)
        
        SPTAddGeneratorListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<GeneratorComponent>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
        
    }
    
    deinit {
        SPTRemoveGeneratorListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
    
    var sourceObjectTypeName: String {
        MeshRegistry.standard.recordById(SPTGetGenerator(object).sourceMeshId)!.name.capitalizingFirstLetter()
    }
    
    var sourceObjectIconName: String {
        MeshRegistry.standard.recordById(SPTGetGenerator(object).sourceMeshId)!.iconName
    }
    
    func updateSourceMesh(_ meshId: SPTMeshId) {
        SPTUpdateGeneratorSourceMesh(object, meshId)
    }
    
    override var subcomponents: [Component]? { [transformation] }
}


struct GeneratorView: View {
    
    @ObservedObject var generatorComponent: GeneratorComponent
    @State private var editedComponent: Component?
    @State private var showsTemplateObjectSelector = false
    
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
            TemplateObjectSelector { meshId in
                generatorComponent.updateSourceMesh(meshId)
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
        let data = SampleSceneData()
        
        return NavigationView {
            GeneratorView(generatorComponent: data.makeGenerator(sourceMeshName: "sphere", quantity: 5))
                .environmentObject(data.sceneViewModel)
                .navigationBarHidden(true)
        }
    }
}
