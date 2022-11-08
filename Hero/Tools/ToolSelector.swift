//
//  ToolSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.10.22.
//

import SwiftUI


fileprivate let toolTitleFontSize = 13.0
fileprivate let toolPathFontSize = 13.0

struct ToolSelector: View {
    
    @Binding var activeToolViewModel: ToolViewModel
    let toolViewModels: [ToolViewModel]
    
    private var horizontalPadding: CGFloat = 0.0
    @Namespace private var matchedGeometryEffectNamespace
    
    init(activeToolViewModel: Binding<ToolViewModel>, toolViewModels: [ToolViewModel]) {
        _activeToolViewModel = activeToolViewModel
        self.toolViewModels = toolViewModels
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0.0) {
                    ForEach(toolViewModels) { toolViewModel in
                        itemForToolViewModel(toolViewModel, scrollViewProxy: scrollViewProxy)
                            .background {
                                RoundedRectangle(cornerRadius: 8.0)
                                    .foregroundColor(.systemFill)
                                    .visible(activeToolViewModel == toolViewModel)
                                    .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: self.activeToolViewModel == toolViewModel)
                            }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .onChange(of: activeToolViewModel) { newValue in
                    withAnimation {
                        scrollViewProxy.scrollTo(newValue.id)
                    }
                }
            }
            .tint(.primary)
        }
    }
    
    func itemForToolViewModel(_ toolViewModel: ToolViewModel, scrollViewProxy: ScrollViewProxy) -> some View {
        HStack(spacing: 4.0) {
            Button {
                withAnimation {
                    if activeToolViewModel == toolViewModel {
                        activeToolViewModel.activeComponent = nil
                    } else {
                        activeToolViewModel = toolViewModel
                    }
                }
            } label: {
                HStack(spacing: activeToolViewModel == toolViewModel ? 6.0 : 0.0) {
                    Image(toolViewModel.tool.iconName)
                        .imageScale(.large)
                        .shadow(radius: 0.5)
                    if activeToolViewModel == toolViewModel {
                        Text(toolViewModel.tool.title.replacingOccurrences(of: " ", with: "\n"))
                            .multilineTextAlignment(.leading)
                            .font(.system(size: toolTitleFontSize, weight: .medium))
                    }
                }
            }
            if activeToolViewModel == toolViewModel {
                ToolComponentPathView(toolViewModel: activeToolViewModel, scrollViewProxy: scrollViewProxy)
            }
        }
        .frame(height: Self.itemHeight)
        .frame(minWidth: Self.itemMinWidth)
        .padding(.horizontal, Self.itemHorizontalPadding)
        .id(toolViewModel.id)
    }
    
    func contentHorizontalPadding(_ padding: CGFloat) -> ToolSelector {
        var selector = self
        selector.horizontalPadding = padding
        return selector
    }
    
    static let itemHeight = 48.0
    static let itemHorizontalPadding = 8.0
    static let itemMinWidth = itemHeight - 2 * itemHorizontalPadding + 4.0
    
}

fileprivate struct ToolComponentPathView: View {
    
    @ObservedObject var toolViewModel: ToolViewModel
    let scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        ToolComponentPathItemView(component: toolViewModel.activeComponent, activeComponent: $toolViewModel.activeComponent)
            .font(.system(size: toolPathFontSize))
            .onChange(of: toolViewModel.activeComponent) { _ in
                withAnimation {
                    scrollViewProxy.scrollTo(toolViewModel.id, anchor: .trailing)
                }
            }
    }
}

fileprivate struct ToolComponentPathItemView: View {
    
    let component: Component?
    @Binding var activeComponent: Component?
    
    var body: some View {
        if let component = component, component.parent != nil {
            HStack(spacing: 4.0) {
                ToolComponentPathItemView(component: component.parent, activeComponent: $activeComponent)
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundColor(.secondary)
                Button {
                    withAnimation {
                        activeComponent = component
                    }
                } label: {
                    Text(component.title)
                        .fixedSize()
                        .frame(minWidth: 44.0, alignment: .leading)
                }
            }
            .id(component.id)
        }
    }
    
}

struct ToolSelector_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var activeToolViewModel: ToolViewModel = Self.inspectToolViewModel
        
        var body: some View {
            ToolSelector(activeToolViewModel: $activeToolViewModel, toolViewModels: Self.toolViewModels)
                .contentHorizontalPadding(16.0)
        }
        
        static let sceneViewModel = SceneViewModel()
        static let inspectToolViewModel = InspectToolViewModel(sceneViewModel: sceneViewModel)
        static let moveToolViewModel = MoveToolViewModel(sceneViewModel: sceneViewModel)
        static let orientToolViewModel = OrientToolViewModel(sceneViewModel: sceneViewModel)
        static let scaleToolViewModel = ScaleToolViewModel(sceneViewModel: sceneViewModel)
        static let animatePositionToolView = AnimatePositionToolViewModel(sceneViewModel: sceneViewModel)
        static let toolViewModels: [ToolViewModel] = [
            inspectToolViewModel,
            moveToolViewModel,
            orientToolViewModel,
            scaleToolViewModel,
            animatePositionToolView,
        ]
    }
    
    static var previews: some View {
        ContentView()
    }
}
