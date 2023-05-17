//
//  ActionBar.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.11.22.
//

import SwiftUI


struct ActionBar: View {
    
    @Binding var showsNewObjectView: Bool
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneGraph: SceneGraph
    
    var body: some View {
        VStack(spacing: 0.0) {
            item(iconName: "trash") {
                destroyObject(sceneViewModel.selectedObject!)
            }
            .disabled(!sceneViewModel.isObjectSelected)
            
            item(iconName: "plus.square.on.square") {
                duplicateObject(sceneViewModel.selectedObject!)
            }
            .disabled(!sceneViewModel.isObjectSelected)
            
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
    
    func destroyObject(_ object: SPTObject) {
        if object == sceneViewModel.selectedObject {
            sceneViewModel.selectedObject = nil
        }
        if object == sceneViewModel.focusedObject {
            sceneViewModel.focusedObject = nil
        }
        
        // Schedule object removal at the end of the run loop when
        // SwiftUI already processed all view lifecycle events
        let runLoopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, false, 0, { _, _ in
            self.editingParams.onObjectDestroy(object)
            self.sceneGraph.destroyObject(object)
        })
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserver, .defaultMode)
     
    }
    
    func duplicateObject(_ original: SPTObject) {
        let duplicate = sceneGraph.duplicateObject(original)
        editingParams.onObjectDuplicate(original: original, duplicate: duplicate)
        sceneViewModel.selectedObject = duplicate
        sceneViewModel.focusedObject = duplicate
    }
    
    static let itemSize = CGSize(width: 44.0, height: 44.0)
    static let slotCount = 3
}

