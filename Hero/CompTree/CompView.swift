//
//  CompView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI

fileprivate let navigationAnimation = Animation.easeOut(duration: 0.25)

struct CompView<SCV>: View where SCV: View {
    
    let compId: Int
    let title: String
    let subtitle: String?
    let indexPath: IndexPath
    let subsView: SCV
    @Binding var activeIndexPath: IndexPath
    
    @StateObject fileprivate var controller: CompControllerBase
    @Namespace private var matchedGeometryEffectNamespace
    
    init(compId: Int, title: String, subtitle: String?, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>, controllerProvider: @escaping () -> CompControllerBase, @ViewBuilder content: () -> SCV) {
        self.compId = compId
        self.title = title
        self.subtitle = subtitle
        self.indexPath = indexPath
        self.subsView = content()
        _activeIndexPath = activeIndexPath
        _controller = .init(wrappedValue: controllerProvider())
    }
    
    var body: some View {
        ZStack {
            compTextView()
                .preference(key: ActiveCompPropertyChangePreferenceKey.self, value: isActive && controller.activePropertyIndex != nil ? .init(compId: compId, controller: controller, activePropertyIndex: controller.activePropertyIndex!) : nil)
                .preference(key: DisclosedCompsPreferenceKey.self, value: isDisclosed ? [.init(compId: compId, title: title, subtitle: subtitle, indexPath: indexPath, controller: controller)] : [])
                
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                if let properties = controller.properties {
                    propertyViews(properties)
                }
                
                subsView
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .onAppear {
            
            if isDisclosed {
                controller.disclose()
            }
            
            if isActive {
                controller.activate()
            }
        }
        .onDisappear {
            if isActive {
                controller.deactivate()
            }
            
            if isDisclosed {
                controller.close()
            }
        }
        .onChange(of: activeIndexPath) { [activeIndexPath] newValue in
            if activeIndexPath == indexPath {
                controller.deactivate()
            }
            
            if activeIndexPath.starts(with: indexPath) {
                if !newValue.starts(with: indexPath) {
                    controller.close()
                }
            } else {
                if newValue.starts(with: indexPath) {
                    controller.disclose()
                }
            }
            
            if newValue == indexPath {
                controller.activate()
            }
        }
    }
    
    private func compTextView() -> some View {
        textView(title)
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 1.0)
            }
            .scaleEffect(x: textHorizontalScale)
            .visible(isChildOfActive)
            .onTapGesture {
                withAnimation(navigationAnimation) {
                    activeIndexPath = indexPath
                }
            }
            .allowsHitTesting(isChildOfActive)
    }
    
    private func textView(_ title: String) -> some View {
        Text(title)
            .font(Font.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
            .contentShape(Rectangle())
    }
    
    private var textHorizontalScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
    private func propertyViews(_ properties: [String]) -> some View {
        ForEach(Array(properties.enumerated()), id: \.element, content: { index, property in
            textView(property)
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(index == controller.activePropertyIndex)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: index == controller.activePropertyIndex)
                }
                .onTapGesture {
                    guard index != controller.activePropertyIndex else {
                        return
                    }
                    controller.onActivePropertyWillChange()
                    withAnimation(navigationAnimation) {
                        controller.activePropertyIndex = index
                    }
                    controller.onActivePropertyDidChange()
                }
            
        })
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    private var isActive: Bool {
        indexPath == activeIndexPath
    }
    
    private var isChildOfActive: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeIndexPath
    }
    
    private var isDisclosed: Bool {
        activeIndexPath.starts(with: indexPath)
    }
    
    private var distanceToActiveAncestor: Int? {
        guard indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return indexPath.count - activeIndexPath.count
    }
    
}
