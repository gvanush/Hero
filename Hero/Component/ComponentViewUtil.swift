//
//  ComponentViewUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import SwiftUI


struct SceneEditableParam: View {
    
    let title: String
    let value: String?
    let indent: Int
    let editAction: () -> Void
    
    init(title: String, value: String?, indent: Int = 0, editAction: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.indent = indent
        self.editAction = editAction
    }
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: CGFloat(indent) * 16.0)
            Text(title)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
            Button(action: editAction) {
                Image(systemName: "slider.horizontal.3")
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
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.large)
            }
        }
    }
}
