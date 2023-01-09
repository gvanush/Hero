//
//  ActionBar.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.11.22.
//

import SwiftUI


class ActionBarModel: ObservableObject {
    
    @Published fileprivate private(set) var commonSectionItems = [AnyActionBarItem]()
    @Published fileprivate private(set) var toolSectionItems = [AnyActionBarItem]()
    @Published fileprivate private(set) var objectSectionItems = [AnyActionBarItem]()
    
    fileprivate var animateChanges = false
    
    fileprivate var allItemsCount: Int {
        commonSectionItems.count + toolSectionItems.count + objectSectionItems.count
    }
    
    fileprivate func updateCommonSectionItems(_ items: [AnyActionBarItem]) {
        if animateChanges {
            withAnimation {
                commonSectionItems = items
            }
        } else {
            commonSectionItems = items
        }
    }
    
    fileprivate func updateToolSectionItems(_ items: [AnyActionBarItem]) {
        if animateChanges {
            withAnimation {
                toolSectionItems = items
            }
        } else {
            toolSectionItems = items
        }
    }
    
    fileprivate func updateObjectSectionItems(_ items: [AnyActionBarItem]) {
        if animateChanges {
            withAnimation {
                objectSectionItems = items
            }
        } else {
            objectSectionItems = items
        }
    }
    
    func onAppear() {
        animateChanges = true
    }
    
}

struct ActionBarItemReader<Content>: View where Content: View {
    
    let model: ActionBarModel
    let content: Content
    
    init(model: ActionBarModel, @ViewBuilder content: () -> Content) {
        self.model = model
        self.content = content()
    }
    
    var body: some View {
        content
            .onPreferenceChange(ActionBarPreferenceKey<ActionBar.CommonSection>.self) { items in
                model.updateCommonSectionItems(items)
            }
            .onPreferenceChange(ActionBarPreferenceKey<ActionBar.ToolSection>.self) { items in
                model.updateToolSectionItems(items)
            }
            .onPreferenceChange(ActionBarPreferenceKey<ActionBar.ObjectSection>.self) { items in
                model.updateObjectSectionItems(items)
            }
    }
    
}

struct ActionBar: View {
    
    enum CommonSection {}
    enum ToolSection {}
    enum ObjectSection {}
    
    @ObservedObject var model: ActionBarModel
    
    var body: some View {
        VStack(spacing: 4.0) {
            sectionView(items: model.commonSectionItems)
            
            sectionView(items: model.toolSectionItems)
                .tint(.primary)
            
            sectionView(items: model.objectSectionItems)
                .tint(.primarySelectionColor)
        }
        // This is a weird fix for button tap area not being matched
        // to its content size when it is inside a scroll view
        .onTapGesture {}
        .onAppear {
            model.onAppear()
        }
    }
    
    func sectionView(items: [AnyActionBarItem]) -> some View {
        Group {
            if !items.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0.0) {
                        ForEach(items.reversed()) { item in
                            item.view
                                .frame(size: Self.itemSize)
                                .transition(.identity)
                        }
                        .imageScale(.medium)
                    }
                }
                .frame(width: Self.itemSize.width, height: CGFloat(min(items.count, Self.maxSlotCount)) * Self.itemSize.height)
                .background(Material.thin)
                .cornerRadius(10.0)
                .shadow(radius: 1.0)
            }
        }
    }
    
    var divider: some View {
        Divider()
            .padding(.horizontal, 4.0)
            .transition(.identity)
    }
    
    static let itemSize = CGSize(width: 44.0, height: 44.0)
    static let maxSlotCount = 3
}
    
extension View {
    func actionBarCommonSection(@ActionBarContentBuilder content: () -> [AnyActionBarItem]) -> some View {
        self.preference(key: ActionBarPreferenceKey<ActionBar.CommonSection>.self, value: content())
    }
    
    func actionBarToolSection(@ActionBarContentBuilder content: () -> [AnyActionBarItem]) -> some View {
        self.preference(key: ActionBarPreferenceKey<ActionBar.ToolSection>.self, value: content())
    }
    
    func actionBarObjectSection(@ActionBarContentBuilder content: () -> [AnyActionBarItem]) -> some View {
        self.preference(key: ActionBarPreferenceKey<ActionBar.ObjectSection>.self, value: content())
    }
}


fileprivate struct ActionBarPreferenceKey<Section>: PreferenceKey {
    static var defaultValue: [AnyActionBarItem] { [] }
    
    static func reduce(value: inout [AnyActionBarItem], nextValue: () -> [AnyActionBarItem]) {
        value.append(contentsOf: nextValue())
    }
}



struct ActionBar_Previews: PreviewProvider {
    
    struct ContainerView: View {
        
        @StateObject var actionBarModel = ActionBarModel()
        
        @State var axis = Axis.x
        
        var body: some View {
            ActionBarItemReader(model: actionBarModel) {
                ZStack {
                    Color.lightGray
                        .actionBarCommonSection {
                            ActionBarButton(iconName: "plus") {
                                
                            }
                            ActionBarMenu(title: "Model", iconName: "circle", selected: $axis)
                        }
                        .actionBarObjectSection {
                            ActionBarButton(iconName: "minus") {
                                
                            }
                        }
                    
                    ActionBar(model: actionBarModel)
                }
            }
        }
        
    }
    
    static var previews: some View {
        ContainerView()
    }
    
}
