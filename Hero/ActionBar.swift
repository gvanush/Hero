//
//  ActionBar.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.11.22.
//

import SwiftUI


struct ActionBar: View {
    
    @Binding var showsNewObjectView: Bool
    
    @EnvironmentObject var scene: MainScene
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    var body: some View {
        VStack(spacing: 0.0) {
            item(iconName: "trash") {
                editingParams.onObjectDestroy(scene.selectedObject!.sptObject)
                scene.selectedObject!.die()
            }
            .disabled(!scene.isObjectSelected)
            
            item(iconName: "plus.square.on.square") {
                let clone = scene.selectedObject!.clone()
                scene.selectedObject = clone
                scene.focusedObject = clone
            }
            .disabled(!scene.isObjectSelected)
            
            item(iconName: "plus") {
                showsNewObjectView = true
            }
            
        }
        .frame(width: Self.itemSize.width, height: CGFloat(Self.slotCount) * Self.itemSize.height)
        .background(Material.thin)
        .cornerRadius(10.0)
        .shadow(radius: 1.0)
    }
    
    func item(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .imageScale(.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    static let itemSize = CGSize(width: 44.0, height: 44.0)
    static let slotCount = 3
}

