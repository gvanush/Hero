//
//  ActionsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.10.22.
//

import SwiftUI

struct ActionItem: Identifiable {
    
    var id: String {
        iconName
    }
    
    let iconName: String
    var disabled: () -> Bool = { false }
    let action: () -> Void
}

struct ActionsView: View {
    
    @Binding var primaryActions: [ActionItem]
    @Binding var secondaryActions: [ActionItem]?
    
    var body: some View {
        VStack {
            ForEach(primaryActions.reversed()) { item in
                viewFor(item)
            }
            if let objectActions = secondaryActions {
                Divider()
                ForEach(objectActions.reversed()) { item in
                    viewFor(item)
                        .foregroundColor(Color.objectSelectionColor)
                }
            }
        }
        .frame(width: Self.itemSize.width)
    }
    
    func viewFor(_ item: ActionItem) -> some View {
        Button(action: item.action) {
            Image(systemName: item.iconName)
                .imageScale(.large)
                .frame(width: Self.itemSize.width, height: Self.itemSize.height)
        }
        .disabled(item.disabled())
    }
    
    static let itemSize = CGSize(width: 44.0, height: 44.0)
    
}

struct ActionsView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State private var genericActions = [
            ActionItem(iconName: "plus", action: {}),
            ActionItem(iconName: "plus.square.on.square", action: {}),
            ActionItem(iconName: "slider.horizontal.3", action: {}),
            ActionItem(iconName: "trash", action: {})
        ]
        @State private var objectActions: [ActionItem]? = [
            ActionItem(iconName: "bolt.slash", action: {}),
        ]
        
        var body: some View {
            ZStack {
                Color.gray
                HStack {
                    ActionsView(primaryActions: $genericActions, secondaryActions: $objectActions)
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
