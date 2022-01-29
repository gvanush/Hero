//
//  PropertyTreeNavigationView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.01.22.
//

import SwiftUI

fileprivate let navigationAnimation = Animation.easeOut(duration: 0.25)


fileprivate class NodeData: ObservableObject {
    let indexPath: IndexPath
    
    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}


fileprivate class ActiveNodeData: ObservableObject {
    @Published var indexPath: IndexPath
    
    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}


struct PropertyNode<P, V0, V1, V2, V3, V4>: View
where P: Property, P.AllCases: RandomAccessCollection, V0: View, V1: View, V2: View, V3: View, V4: View {
    
    let title: String
    let views: (V0?, V1?, V2?, V3?, V4?)
    @Binding var selected: P?
    @State var selectionFrame: CGRect?
    @EnvironmentObject private var data: NodeData
    @EnvironmentObject private var activeData: ActiveNodeData
    @Namespace private var matchedAnimationNamespace
    
    init(_ title: String, selected: Binding<P?>) where V0 == EmptyView, V1 == EmptyView, V2 == EmptyView, V3 == EmptyView, V4 == EmptyView {
        self.title = title
        self.views = (EmptyView(), EmptyView(), EmptyView(), EmptyView(), EmptyView())
        _selected = selected
    }
    
    init(_ title: String, selected: Binding<P?>, @ViewBuilder only content: () -> V0) where V1 == EmptyView, V2 == EmptyView, V3 == EmptyView, V4 == EmptyView {
        self.title = title
        self.views = (content(), EmptyView(), EmptyView(), EmptyView(), EmptyView())
        _selected = selected
    }

    init(_ title: String, @ViewBuilder only content: () -> V0) where P == VoidProperty, V1 == EmptyView, V2 == EmptyView, V3 == EmptyView, V4 == EmptyView {
        self.title = title
        self.views = (content(), EmptyView(), EmptyView(), EmptyView(), EmptyView())
        _selected = .constant(nil)
    }
    
    init(_ title: String, selected: Binding<P?>, @ViewBuilder _ content: () -> TupleView<(V0, V1)>) where V2 == EmptyView, V3 == EmptyView, V4 == EmptyView {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, EmptyView(), EmptyView(), EmptyView())
        _selected = selected
    }
    
    init(_ title: String, @ViewBuilder _ content: () -> TupleView<(V0, V1)>) where P == VoidProperty, V2 == EmptyView, V3 == EmptyView, V4 == EmptyView {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, EmptyView(), EmptyView(), EmptyView())
        _selected = .constant(nil)
    }
    
    init(_ title: String, selected: Binding<P?>, @ViewBuilder _ content: () -> TupleView<(V0, V1, V2)>) where V3 == EmptyView, V4 == EmptyView {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, content.2, EmptyView(), EmptyView())
        _selected = selected
    }
    
    init(_ title: String, @ViewBuilder _ content: () -> TupleView<(V0, V1, V2)>) where P == VoidProperty, V3 == EmptyView, V4 == EmptyView {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, content.2, EmptyView(), EmptyView())
        _selected = .constant(nil)
    }
    
    init(_ title: String, selected: Binding<P?>, @ViewBuilder _ content: () -> TupleView<(V0, V1, V2, V3)>) where V4 == EmptyView {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, content.2, content.3, EmptyView())
        _selected = selected
    }
    
    init(_ title: String, @ViewBuilder _ content: () -> TupleView<(V0, V1, V2, V3)>) where P == VoidProperty, V4 == EmptyView {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, content.2, content.3, EmptyView())
        _selected = .constant(nil)
    }
    
    init(_ title: String, selected: Binding<P?>, @ViewBuilder _ content: () -> TupleView<(V0, V1, V2, V3, V4)>) {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, content.2, content.3, content.4)
        _selected = selected
    }
    
    init(_ title: String, @ViewBuilder _ content: () -> TupleView<(V0, V1, V2, V3, V4)>) where P == VoidProperty {
        self.title = title
        let content = content().value
        self.views = (content.0, content.1, content.2, content.3, content.4)
        _selected = .constant(nil)
    }
    
    var body: some View {
        ZStack {
            textViewFor(title)
                .overlay {
                    VStack {
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.objectSelectionColor)
                    }
                    .padding(.bottom, 5.0)
                }
                .scaleEffect(textScale)
                .visible(isChildOfActive)
                .onTapGesture {
                    withAnimation(navigationAnimation) {
                        activeData.indexPath = data.indexPath
                    }
                }
                .allowsHitTesting(isChildOfActive)
                .preference(key: ActiveNodeTitlePreferenceKey.self, value: isActive ? title : nil)
                .preference(key: ActiveNodeParentTitlePreferenceKey.self, value: isParentOfActive ? title : nil)
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                propertyViews()
                
                views.0
                    .environmentObject(NodeData(indexPath: data.indexPath.appending(0)))
                views.1
                    .environmentObject(NodeData(indexPath: data.indexPath.appending(1)))
                views.2
                    .environmentObject(NodeData(indexPath: data.indexPath.appending(2)))
                views.3
                    .environmentObject(NodeData(indexPath: data.indexPath.appending(3)))
                views.4
                    .environmentObject(NodeData(indexPath: data.indexPath.appending(4)))
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
    }
    
    var isActive: Bool {
        data.indexPath == activeData.indexPath
    }
    
    var isChildOfActive: Bool {
        data.indexPath.count - activeData.indexPath.count == 1
    }
    
    var isParentOfActive: Bool {
        data.indexPath == activeData.indexPath.dropLast()
    }
    
    var isDisclosed: Bool {
        activeData.indexPath.starts(with: data.indexPath)
    }
    
    func propertyViews() -> some View {
        return ForEach(P.allCases) { property in
            textViewFor(property.title)
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(selected == property)
                        .matchedGeometryEffect(id: "Selected", in: matchedAnimationNamespace, isSource: selected == property)
                }
                .onTapGesture {
                    withAnimation(navigationAnimation) {
                        selected = property
                    }
                }
        }
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    func textViewFor(_ title: String) -> some View {
        Text(title)
            .foregroundColor(.secondary)
            .font(.body)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
            .contentShape(Rectangle())
    }
    
    var textScale: CGFloat {
        guard data.indexPath.starts(with: activeData.indexPath) else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(data.indexPath.count - activeData.indexPath.count))
    }
}


struct PropertyTreeNavigationView<V: View>: View {
    
    let root: V
    @StateObject private var activeData = ActiveNodeData(indexPath: IndexPath())
    @State var activeTitle: String?
    @State var activeParentTitle: String?
    
    init(@ViewBuilder content: () -> V) {
        self.root = content()
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            Spacer()
            Group {
                root
                    .environmentObject(NodeData(indexPath: IndexPath()))
                    .environmentObject(activeData)
            }
            .padding(3.0)
            .frame(maxHeight: 46.0)
            .background(Material.bar)
            .compositingGroup()
            .shadow(radius: 0.5)
            .onPreferenceChange(ActiveNodeTitlePreferenceKey.self) { title in
                activeTitle = title
            }
            .onPreferenceChange(ActiveNodeParentTitlePreferenceKey.self) { title in
                activeParentTitle = title
            }
            
            BottomBar()
                .overlay {
                    HStack {
                        backButton
                        if let activeTitle = activeTitle {
                            Text(activeTitle)
                                .font(.headline)
                                .lineLimit(1)
                                .transition(.identity)
                                .id(activeTitle)
                                .layoutPriority(1.0)
                        }
                            
                        editPropertyButton
                    }
                    .padding(.horizontal, 8.0)
                    .tint(.objectSelectionColor)
                }
        }
    }
    
    var backButton: some View {
        Button {
            withAnimation(navigationAnimation) {
                _ = activeData.indexPath.removeLast()
            }
        } label: {
            HStack(spacing: 0.0) {
                Image(systemName: "chevron.left")
                if let title = activeParentTitle {
                    Text(title)
                        .font(.callout)
                        .lineLimit(1)
                        .transition(.identity)
                        .id(title)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .visible(!activeData.indexPath.isEmpty)
    }
 
    var editPropertyButton: some View {
        Button {
            // TODO:
        } label: {
            Image(systemName: "pencil.circle")
                .imageScale(.large)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
}


fileprivate struct ActiveNodeTitlePreferenceKey: PreferenceKey {
    static var defaultValue: String? = nil

    static func reduce(value: inout String?, nextValue: () -> String?) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}

fileprivate struct ActiveNodeParentTitlePreferenceKey: PreferenceKey {
    static var defaultValue: String? = nil

    static func reduce(value: inout String?, nextValue: () -> String?) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}


struct PropertyTreeNavigationView_Previews: PreviewProvider {
    
    struct ContainerView: View {
        
        @State var positionSelection: Axis? = .x
        @State var scaleSelection: Axis? = .x
        @State var orientationSelection: Axis? = .x
        @State var dummySelection: Axis? = .x
        
        var body: some View {
            PropertyTreeNavigationView {
                PropertyNode("Transformation") {
                    PropertyNode("Position", selected: $positionSelection)
                    PropertyNode("Scale", selected: $scaleSelection)
                    PropertyNode("Orientation", selected: $orientationSelection)
                    if positionSelection == .x {
                        PropertyNode("More", selected: $orientationSelection)
                    } else {
                        PropertyNode("MoreX", selected: $orientationSelection)
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
