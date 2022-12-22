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

struct MultiVariantParam<O>: View
where O: CaseIterable, O.AllCases: RandomAccessCollection, O: Identifiable, O: Equatable, O: Hashable, O: Displayable {
    
    let title: String
    let editIconName: String
    @Binding var selected: O
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(selected.displayName)
                .foregroundColor(.secondary)
            Menu(content: {
                ForEach(O.allCases) { option in
                    Button {
                        selected = option
                    } label: {
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if selected == option {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    }
                }
            }, label: {
                Image(systemName: editIconName)
                    .imageScale(.large)
            })
        }
    }
    
}
