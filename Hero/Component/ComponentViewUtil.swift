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
    let editAction: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
            Button(action: editAction) {
                Image(systemName: "slider.horizontal.below.rectangle")
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
