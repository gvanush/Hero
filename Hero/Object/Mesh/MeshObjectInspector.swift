//
//  MeshInspector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.08.22.
//

import SwiftUI


class MeshObjectComponent: Component {

    let object: SPTObject
    lazy private(set) var transformation = TransformationComponent(object: self.object, parent: self)
    
    init(object: SPTObject) {
        
        self.object = object
        
        super.init(title: "Mesh", parent: nil)
    }
    
    var objectName: String {
        SPTMetadataGet(object).name.capitalizingFirstLetter()
    }
    
    override var subcomponents: [Component]? { [transformation] }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
}


struct MeshObjectInspector: View {
    
    @StateObject var meshComponent: MeshObjectComponent
    @State private var editedComponent: Component?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            TransformationComponentView(component: meshComponent.transformation, editedComponent: $editedComponent)
                .navigationTitle(meshComponent.objectName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
        .fullScreenCover(item: $editedComponent, onDismiss: {}, content: { editedComponent in
            EditMeshObjectView(activeComponent: editedComponent)
                .environmentObject(meshComponent)
        })
    }
    
}


struct EditMeshObjectView: View {
    
    @State private var activeComponent: Component
    @State private var isNavigating = false
    @EnvironmentObject var meshComponent: MeshObjectComponent
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    static let editComponentViewProvider = MeshObjectComponentActionViewProvider()
    
    init(activeComponent: Component) {
        _activeComponent = State<Component>(initialValue: activeComponent)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    SceneView(model: sceneViewModel, uiSafeAreaInsets: geometry.safeAreaInsets.bottomInseted(ComponentTreeNavigationView.height), isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation)) {
                        activeComponent.accept(Self.editComponentViewProvider)
                    }
                    .selectionEnabled(false)
                    .ignoresSafeArea()
                    VStack {
                        Spacer()
                        ComponentTreeNavigationView(rootComponent: meshComponent, activeComponent: $activeComponent)
                            .offset(y: isNavigating ? ComponentTreeNavigationView.height + geometry.safeAreaInsets.bottom : 0.0)
                    }
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
                .navigationTitle("Edit Mesh")
            }
        }
    }
    
}