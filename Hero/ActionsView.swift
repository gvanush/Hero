//
//  ActionsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.10.22.
//

import SwiftUI


fileprivate let itemSize = CGSize(width: 44.0, height: 44.0)

struct ActionItem: Identifiable {
    
    var id: String {
        iconName
    }
    
    let iconName: String
    var disabled = false
    let action: () -> Void
}

struct ActionsView: View {
    
    @ObservedObject var sceneViewModel: SceneViewModel
    @Binding var activeToolViewModel: ToolViewModel
    
    @State private var showsNewObjectView = false
    @State private var showsSelectedObjectInspector = false
    
    
    var body: some View {
        VStack {
            ActionsGroupView(actions: defaultActions)
            ToolActionsView(toolViewModel: activeToolViewModel)
        }
        .frame(width: itemSize.width)
        .sheet(isPresented: $showsNewObjectView) {
            NewObjectView() { meshId in
                sceneViewModel.createNewObject(meshId: meshId)
            }
        }
        .sheet(isPresented: $showsSelectedObjectInspector) {
            MeshObjectInspector(meshComponent: MeshObjectComponent(object: sceneViewModel.selectedObject!, sceneViewModel: sceneViewModel))
                .environmentObject(sceneViewModel)
        }
    }
    
    var defaultActions: [ActionItem] {
        [
            ActionItem(iconName: "plus") {
                showsNewObjectView = true
            },
            ActionItem(iconName: "plus.square.on.square", disabled: !sceneViewModel.isObjectSelected) {
                sceneViewModel.duplicateObject(sceneViewModel.selectedObject!)
            },
            ActionItem(iconName: "slider.horizontal.3", disabled: !sceneViewModel.isObjectSelected) {
                showsSelectedObjectInspector = true
            },
            ActionItem(iconName: "trash", disabled: !sceneViewModel.isObjectSelected) {
                sceneViewModel.destroySelected()
            }
        ]
    }
    
}

fileprivate struct ToolActionsView: View {
    
    @ObservedObject var toolViewModel: ToolViewModel
    
    var body: some View {
        if let actions = toolViewModel.actions {
            Divider()
            ActionsGroupView(actions: actions)
                .foregroundColor(Color.primary)
        }
        if let component = toolViewModel.activeComponent {
            ToolComponentActionsView(component: component)
        }
    }
    
}

fileprivate struct ToolComponentActionsView: View {
    
    @ObservedObject var component: Component
    
    var body: some View {
        if !component.actions.isEmpty {
            Divider()
            ActionsGroupView(actions: component.actions)
                .foregroundColor(Color.objectSelectionColor)
        }
    }
    
}

fileprivate struct ActionsGroupView: View {
    
    let actions: [ActionItem]
    
    var body: some View {
        ForEach(actions.reversed()) { item in
            viewFor(item)
        }
    }
    
    func viewFor(_ item: ActionItem) -> some View {
        Button(action: item.action) {
            Image(systemName: item.iconName)
                .imageScale(.large)
                .frame(width: itemSize.width, height: itemSize.height)
        }
        .disabled(item.disabled)
    }
    
}



struct ActionsView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @StateObject var sceneViewModel = SceneViewModel()
        @State var activeToolViewModel: ToolViewModel = InspectToolViewModel(sceneViewModel: SceneViewModel())
        
        var body: some View {
            ZStack {
                Color.gray
                HStack {
                    ActionsView(sceneViewModel: sceneViewModel, activeToolViewModel: $activeToolViewModel)
                        .padding(3.0)
                        .background(Material.bar)
                        .cornerRadius(3.0, corners: [.topRight, .bottomRight])
                    Spacer()
                }
            }
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
