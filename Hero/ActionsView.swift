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

class ActionsViewModel: ObservableObject {
    
    
    
}

struct ActionsView: View {
    
    let defaultActions: [ActionItem]
    @Binding var activeToolViewModel: ToolViewModel
    
    var body: some View {
        VStack {
            ActionsGroupView(actions: defaultActions)
            ToolActionsView(toolViewModel: activeToolViewModel)
        }
        .frame(width: itemSize.width)
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
            ComponentActionsView(component: component)
        }
    }
    
}

fileprivate struct ComponentActionsView: View {
    
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
                    ActionsView(defaultActions: defaultActions, activeToolViewModel: $activeToolViewModel)
                        .padding(3.0)
                        .background(Material.bar)
                        .cornerRadius(3.0, corners: [.topRight, .bottomRight])
                    Spacer()
                }
            }
        }
        
        var defaultActions: [ActionItem] {
            [
                ActionItem(iconName: "plus") {
                    
                },
                ActionItem(iconName: "plus.square.on.square", disabled: !sceneViewModel.isObjectSelected) {
                    
                },
                ActionItem(iconName: "slider.horizontal.3", disabled: !sceneViewModel.isObjectSelected) {
                    
                },
                ActionItem(iconName: "trash", disabled: !sceneViewModel.isObjectSelected) {
                    
                }
            ]
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
