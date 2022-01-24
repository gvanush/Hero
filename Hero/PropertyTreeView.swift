//
//  PropertyTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.01.22.
//

import SwiftUI


fileprivate let navigationAnimationDuration = 0.25
fileprivate let navigationAnimation = Animation.easeOut(duration: navigationAnimationDuration)


class PropertyTreeNodeViewModel: ObservableObject {
    
    let title: String
    let subtitle: String?
    let children: [PropertyTreeNodeViewModel]?
    
    init(title: String, subtitle: String? = nil, children: () -> [PropertyTreeNodeViewModel]? = { nil }) {
        self.title = title
        self.subtitle = subtitle
        self.children = children()
    }
    
    func nodeAt(_ indexPath: IndexPath) -> PropertyTreeNodeViewModel? {
        guard !indexPath.isEmpty else {
            return self
        }
        
        guard let children = children else { return nil }
        
        let index = indexPath.first!
        guard index < children.count else {
            return nil
        }
        
        return children[index].nodeAt(indexPath.dropFirst())
    }
    
    var isInode: Bool {
        if let children = children, !children.isEmpty {
            return true
        }
        return false
    }
    
    var hasInodeChild: Bool {
        guard let children = children else { return false }
        
        for child in children {
            if child.isInode {
                return true
            }
        }
        return false
    }
}


struct PropertyTreeView: View {
    
    @ObservedObject var rootModel: PropertyTreeNodeViewModel
    @Binding var activeInodeIndexPath: IndexPath
    @Binding var activeInodeSelectionIndex: Int?
    
    var body: some View {
        VStack(spacing: 0.0) {
            Spacer()
            Group {
                PropertyTreeNodeView(indexPath: IndexPath(), model: rootModel, activeInodeIndexPath: $activeInodeIndexPath, activeInodeSelectionIndex: $activeInodeSelectionIndex)
                    .compositingGroup()
                    .shadow(radius: 0.5)
            }
            .padding(3.0)
            .frame(maxHeight: 46.0)
            .background(Material.bar)
            .compositingGroup()
            .shadow(radius: 0.5)
            
            BottomBar()
                .overlay {
                    HStack {
                        backButton

                        let title = rootModel.nodeAt(activeInodeIndexPath)!.title
                        Text(title)
                            .font(.headline)
                            .lineLimit(1)
                            .transition(.identity)
                            .id(title)
                            .layoutPriority(1.0)
                            
                        editPropertyButton
                    }
                    .padding(.horizontal, 8.0)
                    .tint(.objectSelectionColor)
                }
        }
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
    
    var backButton: some View {
        Button {
            withAnimation {
                _ = activeInodeIndexPath.removeLast()
            }
        } label: {
            HStack(spacing: 0.0) {
                Image(systemName: "chevron.left")
                let title = rootModel.nodeAt(activeInodeIndexPath.dropLast())!.title
                Text(title)
                    .font(.callout)
                    .lineLimit(1)
                    .transition(.identity)
                    .id(title)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .visible(!activeInodeIndexPath.isEmpty)
    }
    
    static let height = 44.0
}


fileprivate struct PropertyTreeNodeView: View {
    
    let indexPath: IndexPath
    @ObservedObject var model: PropertyTreeNodeViewModel
    @Binding var activeInodeIndexPath: IndexPath
    @Binding var activeInodeSelectionIndex: Int?
    @State private var selectionIndex: Int?
    @State private var selectionFrame: CGRect?
    @State private var selectionFrameUpdateEnabled = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                
                if let selectionFrame = selectionFrame {
                    RoundedRectangle(cornerRadius: Self.selectionCornerRadius)
                        .foregroundColor(.systemFill)
                        .frame(maxWidth: isActive ? selectionFrame.width : .infinity,
                               maxHeight: isActive ? selectionFrame.height : .infinity)
                        .position(isActive ? selectionFrame.center : geometry.frame(in: CoordinateSpace.named(Self.rootCoordinateSpaceName)).center)
                        .visible(isActive)
                }
                    
                if let children = model.children {
                    HStack(spacing: isActive ? Self.itemSpacing : 0.0) {
                        ForEach(children.indices) { index in
                            itemFor(children[index], at: indexPath.appending(index))
                        }
                    }
                    .onPreferenceChange(SelectedItemRecordPreferenceKey.self) { record in
                        guard let record = record, isActive else { return }
                        
                        assert(selectionIndex != nil)
                        
                        let delayFactor = (selectionFrame == nil ? 0.5 : 1.0)
                        withAnimation(navigationAnimation) {
                            selectionFrame = record.frame
                        }
                        
                        if record.isInode {
                            withAnimation(navigationAnimation.delay(delayFactor * navigationAnimationDuration)) {
                                activeInodeIndexPath.append(selectionIndex!)
                            }
                            selectionIndex = nil
                        } else {
                            activeInodeSelectionIndex = selectionIndex
                        }
                    }
                }
            }
            
        }
        .frame(maxWidth: isOpen ? .infinity : 0.0)
        .coordinateSpace(name: Self.rootCoordinateSpaceName)
        .onChange(of: activeInodeIndexPath) { [activeInodeIndexPath] newValue in
            
            if isActive {
                activeInodeSelectionIndex = selectionIndex
            }
            
            let isNavigatingBack = (newValue.count < activeInodeIndexPath.count)
            guard isNavigatingBack else { return }
            
            if isActive {
                withAnimation(navigationAnimation.delay(0.75 * navigationAnimationDuration)) {
                    selectionFrame = nil
                }
            } else if isChildOfCurrent {
                selectionFrameUpdateEnabled = false
            }
        }
    }
    
    func itemFor(_ childModel: PropertyTreeNodeViewModel, at indexPath: IndexPath) -> some View {
        let isOpenChild = isActive || activeInodeIndexPath.starts(with: indexPath)
        return ZStack {
            Text(childModel.title)
                .foregroundColor(.secondary)
                .font(.body)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: isOpenChild ? .infinity : 0.0, maxHeight: .infinity)
                .padding(.horizontal, isActive ? 8.0 : 0.0)
                .scaleEffect(textScaleForChildAt(indexPath))
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: SelectedItemRecordPreferenceKey.self, value: {
                                if isActive && selectionIndex == indexPath.last! && selectionFrameUpdateEnabled {
                                    return SelectedItemRecord(isInode: childModel.isInode, frame: geometry.frame(in: CoordinateSpace.named(Self.rootCoordinateSpaceName)))
                                } else {
                                    return nil
                                }
                            }())
                    }
                }
                .overlay(overlayFor(childModel))
                .contentShape(Rectangle())
                .visible(isActive)
                .onTapGesture {
                    selectionIndex = indexPath.last!
                    selectionFrameUpdateEnabled = true
                }
                .allowsHitTesting(isActive)
                
            if model.isInode {
                PropertyTreeNodeView(indexPath: indexPath, model: childModel, activeInodeIndexPath: $activeInodeIndexPath, activeInodeSelectionIndex: $activeInodeSelectionIndex)
            }
        }
    }
    
    func overlayFor(_ model: PropertyTreeNodeViewModel) -> some View {
        Group {
            if model.isInode {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundColor(.objectSelectionColor)
                }
                .padding(.bottom, 5.0)
            } else {
                EmptyView()
            }
        }
    }
    
    func textScaleForChildAt(_ childIndexPath: IndexPath) -> CGFloat {
        guard childIndexPath.starts(with: activeInodeIndexPath) else { return 1.0 }
        return pow(1.2, 1.0 - CGFloat(childIndexPath.count - activeInodeIndexPath.count))
    }
    
    var isOpen: Bool {
        activeInodeIndexPath.starts(with: indexPath)
    }
    
    var isActive: Bool {
        indexPath == activeInodeIndexPath
    }
    
    var isParentOfCurrent: Bool {
        guard !activeInodeIndexPath.isEmpty else {
            return false
        }
        return activeInodeIndexPath.dropLast() == indexPath
    }
    
    var isChildOfCurrent: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeInodeIndexPath
    }
    
    static let rootCoordinateSpaceName = "root"
    static let itemPadding = 4.0
    static let itemSpacing = 4.0
    static let selectionCornerRadius = CGFloat.infinity
}


struct TestView_Previews: PreviewProvider {
    
    struct ContainerView : View {
        
        @StateObject private var treeViewRootModel = Self.createModel()
        @State private var indexPath = IndexPath()
        @State private var selectionIndex: Int?
        
        var body: some View {
            ZStack {
                Color.gray
                PropertyTreeView(rootModel: treeViewRootModel, activeInodeIndexPath: $indexPath, activeInodeSelectionIndex: $selectionIndex)
            }
        }
        
        static func createModel() -> PropertyTreeNodeViewModel {
            PropertyTreeNodeViewModel(title: "Transformation") {
                let position = PropertyTreeNodeViewModel(title: "Postion") {
                    return [PropertyTreeNodeViewModel(title: "X"), PropertyTreeNodeViewModel(title: "Y"), PropertyTreeNodeViewModel(title: "Z")]
                }
                let orienation = PropertyTreeNodeViewModel(title: "Orienation") {
                    return [PropertyTreeNodeViewModel(title: "X"), PropertyTreeNodeViewModel(title: "Y"), PropertyTreeNodeViewModel(title: "Z")]
                }
                let scale = PropertyTreeNodeViewModel(title: "Scale") {
                    return [PropertyTreeNodeViewModel(title: "X"), PropertyTreeNodeViewModel(title: "Y"), PropertyTreeNodeViewModel(title: "Z")]
                }
                return [position, orienation, scale]
            }
        }
    }
    
    static var previews: some View {
        ContainerView()
            
    }
}


fileprivate struct SelectedItemRecord: Equatable {
    let isInode: Bool
    let frame: CGRect
}


fileprivate struct SelectedItemRecordPreferenceKey: PreferenceKey {
    static var defaultValue: SelectedItemRecord?
    static func reduce(value: inout SelectedItemRecord?, nextValue: () -> SelectedItemRecord?) {
        if value == nil {
            value = nextValue()
        }
    }
}
