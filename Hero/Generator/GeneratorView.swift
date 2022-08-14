//
//  GeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI


enum GeneratorComponentProperty: Int, DistinctValueSet, Displayable {
    case quantity
}

class GeneratorComponent: BasicComponent<GeneratorComponentProperty> {
    
    let object: SPTObject
    @SPTObservedComponent private var generator: SPTGenerator
    lazy private(set) var transformation = TransformationComponent(object: self.object, parent: self)
    lazy private(set) var arrangement = ArrangementComponent(arrangement: $generator.arrangement, parent: self)
    
    init(object: SPTObject) {
        
        self.object = object
        _generator = SPTObservedComponent(object: object)
        
        super.init(title: "Generator", selectedProperty: .quantity, parent: nil)
        
        _generator.publisher = self.objectWillChange
        
    }
    
    var sourceObjectTypeName: String {
        MeshRegistry.standard.recordById(generator.sourceMeshId)!.name.capitalizingFirstLetter()
    }
    
    var sourceObjectIconName: String {
        MeshRegistry.standard.recordById(generator.sourceMeshId)!.iconName
    }
    
    func updateSourceMesh(_ meshId: SPTMeshId) {
        generator.sourceMeshId = meshId
    }
    
    var quantity: SPTGeneratorQuantityType {
        set { generator.quantity = newValue }
        get { generator.quantity }
    }
    
    override var subcomponents: [Component]? { [transformation, arrangement] }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
}


struct GeneratorView: View {
    
    @ObservedObject var generatorComponent: GeneratorComponent
    @State private var editedComponent: Component?
    @State private var showsTemplateObjectSelector = false
    
    var body: some View {
        Form {
            Section {
                sourceObjectRow
                SceneEditableParam(title: GeneratorComponentProperty.quantity.displayName, value: "\(generatorComponent.quantity)") {
                    generatorComponent.selectedProperty = .quantity
                    editedComponent = generatorComponent
                }
                SceneEditableCompositeParam(title: generatorComponent.transformation.title, value: nil) {
                    editedComponent = generatorComponent.transformation
                } destionation: {
                    Color.red
                }
            }

            ArrangementView(component: generatorComponent.arrangement, editedComponent: $editedComponent)
        }
        // NOTE: This is necessary for an unknown reason to prevent 'Form' row
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


struct GeneratorView_Previews: PreviewProvider {
    
    static let data = SampleSceneData()
    
    static var previews: some View {
        NavigationView {
            GeneratorView(generatorComponent: GeneratorComponent(object: data.makeGenerator(sourceMeshName: "sphere", quantity: 5)))
                .environmentObject(data.sceneViewModel)
                .navigationBarHidden(true)
        }
    }
}
