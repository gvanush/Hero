//
//  ActionsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.10.22.
//

import SwiftUI


fileprivate let itemSize = CGSize(width: 44.0, height: 44.0)

struct ActionItem: Identifiable, Equatable {
    
    var id: String {
        iconName
    }
    
    let iconName: String
    var disabled = false
    let action: () -> Void
    
    static func == (lhs: ActionItem, rhs: ActionItem) -> Bool {
        lhs.id == rhs.id
    }
}
    
struct ActionsView: View {
    
    let defaultActions: [ActionItem]
    @Binding var activeToolViewModel: ToolViewModel
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0.0) {
                    Color.clear
                        .frame(size: itemSize)
                    Color.clear
                        .frame(size: itemSize)
                    ActionsGroupView(actions: defaultActions, scrollViewProxy: scrollViewProxy)
                    ToolActionsView(toolViewModel: activeToolViewModel, scrollViewProxy: scrollViewProxy)
                }
            }
            .frame(width: itemSize.width, height: 4 * itemSize.height)
            // This is a weird fix for button tap area not being matched
            // to its content size when it is inside a scroll view
            .onTapGesture {}
        }
    }
    
}

fileprivate struct ToolActionsView: View {

    @ObservedObject var toolViewModel: ToolViewModel
    let scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        Group {
            if let actions = toolViewModel.actions {
                Divider()
                    .padding(.horizontal, 4.0)
                ActionsGroupView(actions: actions, scrollViewProxy: scrollViewProxy)
                    .foregroundColor(Color.primary)
            }
            if let component = toolViewModel.activeComponent {
                ComponentActionsView(component: component, scrollViewProxy: scrollViewProxy)
            }
        }
    }

}

fileprivate struct ComponentActionsView: View {

    @ObservedObject var component: Component
    let scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        if !component.actions.isEmpty {
            Divider()
                .padding(.horizontal, 4.0)
            ActionsGroupView(actions: component.actions, scrollViewProxy: scrollViewProxy)
                .foregroundColor(Color.primarySelectionColor)
        }
    }

}

fileprivate struct ActionsGroupView: View {
    
    let actions: [ActionItem]
    let scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        Group {
            ForEach(actions.reversed()) { item in
                viewFor(item)
            }
        }
        .onChange(of: actions) { newValue in
            if let id = newValue.first?.id {
                withAnimation {
                    scrollViewProxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .onAppear {
            if let id = actions.first?.id {
                withAnimation {
                    scrollViewProxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
    }
    
    func viewFor(_ item: ActionItem) -> some View {
        Button(action: item.action) {
            Image(systemName: item.iconName)
                .imageScale(.medium)
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
                        .background(Material.bar)
                        .cornerRadius(12.0)
                    Spacer()
                }
                .padding()
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
