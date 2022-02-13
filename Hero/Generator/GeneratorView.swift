//
//  GeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import SwiftUI


class GeneratorComponent: Component {
    
    enum Property: Int, DistinctValueSet, Displayable {
        case quantity
    }
    
    let object: SPTObject
    @Published var activeProperty: Property? = .quantity
    lazy private(set) var transformation = TransformationComponent(parent: self)
    lazy private(set) var arrangement = ArrangementComponent(object: self.object, parent: self)
    
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
    
    var quantity: SPTGeneratorQuantityType {
        set { SPTUpdateGeneratorQunatity(object, newValue) }
        get { SPTGetGenerator(object).quantity }
    }
    
    override var activePropertyIndex: Int? {
        set { activeProperty = .init(rawValue: newValue) }
        get { activeProperty?.rawValue }
    }
    
    override var properties: [String]? {
        Property.allCaseDisplayNames
    }
    
    override var subcomponents: [Component]? { [transformation, arrangement] }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
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
                SceneEditableParam(title: GeneratorComponent.Property.quantity.displayName, value: "\(generatorComponent.quantity)") {
                    generatorComponent.activeProperty = .quantity
                    editedComponent = generatorComponent
                }
            }
            Section {
                SceneEditableCompositeParam(title: generatorComponent.transformation.title, value: nil) {
                    editedComponent = generatorComponent.transformation
                } destionation: {
                    Color.red
                }
            }
//            Section("Arrangement") {
//                Picker("", selection: <#T##Binding<_>#>, content: <#T##() -> _#>)
//            }
        }
        // NOTE: This is necessary for unknown reason to prevent 'Form' row
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
    static var previews: some View {
        let data = SampleSceneData()
        
        return NavigationView {
            GeneratorView(generatorComponent: data.makeGenerator(sourceMeshName: "sphere", quantity: 5))
                .environmentObject(data.sceneViewModel)
                .navigationBarHidden(true)
        }
    }
}
