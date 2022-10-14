//
//  ComponentViewUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import SwiftUI


struct SceneEditableParam: View {
    
    let title: String
    let valueText: Text
    let indent: Int
    let editAction: () -> Void
    
    init(title: String, valueText: Text, indent: Int = 0, editAction: @escaping () -> Void) {
        self.title = title
        self.valueText = valueText
        self.indent = indent
        self.editAction = editAction
    }
    
    init(title: String, valueString: String, indent: Int = 0, editAction: @escaping () -> Void) {
        self.init(title: title, valueText: Text(valueString), editAction: editAction)
    }
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: CGFloat(indent) * 16.0)
            Text(title)
            Spacer()
            valueText
                .foregroundColor(.secondary)
            Button(action: editAction) {
                Image(systemName: "slider.horizontal.below.rectangle")
                    .imageScale(.large)
            }
        }
    }
}
