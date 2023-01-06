//
//  ActionBarContentBuilder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.11.22.
//

import SwiftUI


protocol ActionBarItem: Hashable {
    
    associatedtype V: View
    
    var view: V { get }
    
}

struct ActionBarItemTagWrapper<T, I>: ActionBarItem where T: Hashable, I: ActionBarItem {
    
    typealias V = I.V
    
    let tag: T
    let item: I
    
    var view: I.V {
        item.view
    }
    
}

extension ActionBarItem {
    
    func tag(_ tag: some Hashable) -> some ActionBarItem {
        ActionBarItemTagWrapper(tag: tag, item: self)
    }
    
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
    
    var view: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(disabled)
    }
    
    static func == (lhs: ActionBarButton, rhs: ActionBarButton) -> Bool {
        lhs.iconName == rhs.iconName && lhs.disabled == rhs.disabled
    }
    
    func hash(into hasher: inout Hasher) {
        iconName.hash(into: &hasher)
        disabled.hash(into: &hasher)
    }
}

struct ActionBarMenu<O>: ActionBarItem
where O: CaseIterable, O.AllCases: RandomAccessCollection, O: Identifiable, O: Equatable, O: Hashable, O: Displayable {

    let title: String
    let iconName: String
    let disabled: Bool
    let selected: Binding<O>
    
    init(title: String, iconName: String, disabled: Bool = false, selected: Binding<O>) {
        self.title = title
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
            Section(title) {
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
            }
        }, label: {
            Image(systemName: iconName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .disabled(disabled)
    }
    
    static func == (lhs: ActionBarMenu<O>, rhs: ActionBarMenu<O>) -> Bool {
        lhs.title == rhs.title && lhs.iconName == rhs.iconName && lhs.disabled == rhs.disabled && lhs.selected.wrappedValue == rhs.selected.wrappedValue
    }
    
    func hash(into hasher: inout Hasher) {
        title.hash(into: &hasher)
        iconName.hash(into: &hasher)
        disabled.hash(into: &hasher)
        selected.wrappedValue.hash(into: &hasher)
    }
}

struct AnyActionBarItem: Equatable, Identifiable {
    
    let id: AnyHashable
    let view: AnyView
    
    init<I>(item: I) where I: ActionBarItem {
        self.id = .init(item)
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
