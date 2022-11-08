//
//  ActionBarContentBuilder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.11.22.
//

import SwiftUI


protocol ActionBarItem {
    
    associatedtype ID: Hashable
    associatedtype V: View
    
    var id: ID { get }
    var view: V { get }
    
}

struct ActionBarButton: ActionBarItem {

    let iconName: String
    let disabled: Bool
    let action: () -> Void
    
    init(iconName: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.iconName = iconName
        self.disabled = disabled
        self.action = action
    }
    
    var id: some Hashable {
        var hasher = Hasher()
        iconName.hash(into: &hasher)
        disabled.hash(into: &hasher)
        return hasher.finalize()
    }
    
    var view: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(disabled)
    }
}

struct ActionBarMenu<O>: ActionBarItem
where O: CaseIterable, O.AllCases: RandomAccessCollection, O: Identifiable, O: Equatable, O: Hashable, O: Displayable {

    let iconName: String
    let disabled: Bool
    let selected: Binding<O>
    
    init(iconName: String, disabled: Bool = false, selected: Binding<O>) {
        self.iconName = iconName
        self.disabled = disabled
        self.selected = selected
    }
    
    var id: some Hashable {
        var hasher = Hasher()
        iconName.hash(into: &hasher)
        disabled.hash(into: &hasher)
        selected.wrappedValue.hash(into: &hasher)
        return hasher.finalize()
    }
    
    var view: some View {
        Menu(content: {
            ForEach(O.allCases) { option in
                Button {
                    selected.wrappedValue = option
                } label: {
                    HStack {
                        Text(option.displayName)
                        Spacer()
                        if selected.wrappedValue == option {
                            Image(systemName: "checkmark.circle")
                                .imageScale(.small)
                        }
                    }
                }
            }
        }, label: {
            Image(systemName: iconName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .disabled(disabled)
    }
}

struct AnyActionBarItem: Equatable, Identifiable {
    
    let id: AnyHashable
    let view: AnyView
    
    init<I>(item: I) where I: ActionBarItem {
        self.id = .init(item.id)
        self.view = .init(item.view)
    }
    
    static func == (lhs: AnyActionBarItem, rhs: AnyActionBarItem) -> Bool {
        lhs.id == rhs.id
    }
    
}


@resultBuilder
struct ActionBarContentBuilder {
    
    static func buildBlock() -> [AnyActionBarItem] {
        []
    }

    static func buildBlock<I>(_ item: I) -> [AnyActionBarItem]
    where I: ActionBarItem {
        [.init(item: item)]
    }
    
    static func buildBlock<I1, I2>(_ item1: I1, _ item2: I2) -> [AnyActionBarItem]
    where I1: ActionBarItem, I2: ActionBarItem {
        [.init(item: item1), .init(item: item2)]
    }
    
    static func buildBlock<I1, I2, I3>(_ item1: I1, _ item2: I2, _ item3: I3) -> [AnyActionBarItem]
    where I1: ActionBarItem, I2: ActionBarItem, I3: ActionBarItem {
        [.init(item: item1), .init(item: item2), .init(item: item3)]
    }
    
    static func buildBlock<I1, I2, I3, I4>(_ item1: I1, _ item2: I2, _ item3: I3, _ item4: I4) -> [AnyActionBarItem]
    where I1: ActionBarItem, I2: ActionBarItem, I3: ActionBarItem, I4: ActionBarItem {
        [.init(item: item1), .init(item: item2), .init(item: item3), .init(item: item4)]
    }
    
    static func buildBlock<I1, I2, I3, I4, I5>(_ item1: I1, _ item2: I2, _ item3: I3, _ item4: I4, _ item5: I5) -> [AnyActionBarItem]
    where I1: ActionBarItem, I2: ActionBarItem, I3: ActionBarItem, I4: ActionBarItem, I5: ActionBarItem {
        [.init(item: item1), .init(item: item2), .init(item: item3), .init(item: item4), .init(item: item5)]
    }
    
}
