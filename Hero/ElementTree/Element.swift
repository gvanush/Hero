//
//  Element.swift
//  Hero
//
//  Created by Vanush Grigoryan on 18.04.23.
//

import SwiftUI

fileprivate let navigationAnimation = Animation.easeOut(duration: 0.25)

typealias ElementProperty = Hashable & CaseIterable & Displayable

protocol Element: View {
    
    var title: String { get }
    
    var indexPath: IndexPath! { get set }
    var _activeIndexPath: Binding<IndexPath>! { get set }
    
    associatedtype C1: Element = EmptyElement
    associatedtype C2: Element = EmptyElement
    associatedtype C3: Element = EmptyElement
    associatedtype C4: Element = EmptyElement
    associatedtype C5: Element = EmptyElement
    
    var content: (C1, C2, C3, C4, C5) { get set }
    
    associatedtype Property: ElementProperty = Never
    var activeProperty: Property { get nonmutating set }
 
    associatedtype FaceView: View
    var faceView: FaceView { get }
    
    associatedtype PropertyView: View
    var propertyView: PropertyView { get }
    
    var namespace: Namespace.ID { get }
    
    func indexPath(_ indexPath: IndexPath) -> Self
    
    func activeIndexPath(_ indexPath: Binding<IndexPath>) -> Self
    
}

extension Element {
    
    var body: some View {
        ZStack {
            faceView
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                propertyView
                
                content.0
                    .indexPath(indexPath.appending(0))
                    .activeIndexPath(_activeIndexPath.projectedValue)
                content.1
                    .indexPath(indexPath.appending(1))
                    .activeIndexPath(_activeIndexPath.projectedValue)
                content.2
                    .indexPath(indexPath.appending(2))
                    .activeIndexPath(_activeIndexPath.projectedValue)
                content.3
                    .indexPath(indexPath.appending(3))
                    .activeIndexPath(_activeIndexPath.projectedValue)
                content.4
                    .indexPath(indexPath.appending(4))
                    .activeIndexPath(_activeIndexPath.projectedValue)
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
    }
    
    var faceView: some View {
        Text(title)
            .font(Font.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
            .contentShape(Rectangle())
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
                    print("set \(String(describing: indexPath))")
                    activeIndexPath = indexPath
                }
            }
            .allowsHitTesting(isChildOfActive)
        
    }
    
    var propertyView: some View {
        ForEach(Array(Property.allCases), id: \.self) { prop in
            Text(prop.displayName)
                .font(Font.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
                .contentShape(Rectangle())
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(prop == activeProperty)
                        .matchedGeometryEffect(id: "Selected", in: namespace, isSource: prop == activeProperty)
                }
                .onTapGesture {
                    withAnimation(navigationAnimation) {
                        activeProperty = prop
                    }
                }
        }
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    var activeIndexPath: IndexPath {
        get {
            _activeIndexPath.wrappedValue
        }
        nonmutating set {
            _activeIndexPath.wrappedValue = newValue
        }
    }
    
    var isActive: Bool {
        indexPath == activeIndexPath
    }
    
    var isChildOfActive: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeIndexPath
    }
    
    var isDisclosed: Bool {
        activeIndexPath.starts(with: indexPath)
    }
    
    func indexPath(_ indexPath: IndexPath) -> Self {
        var copy = self
        copy.indexPath = indexPath
        return copy
    }
    
    func activeIndexPath(_ indexPath: Binding<IndexPath>) -> Self {
        var copy = self
        copy._activeIndexPath = indexPath
        return copy
    }
    
    private var distanceToActiveAncestor: Int? {
        guard indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return indexPath.count - activeIndexPath.count
    }
    
    private var textHorizontalScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
}

extension Element where Property == Never {
    
    var activeProperty: Property {
        get {
            fatalError()
        }
        nonmutating set {
            
        }
    }
    
}

extension Element where C1 == EmptyElement, C2 == EmptyElement, C3 == EmptyElement, C4 == EmptyElement, C5 == EmptyElement {
    
    var content: (C1, C2, C3, C4, C5) {
        get {
            (.init(), .init(), .init(), .init(), .init())
        }
        set {
            
        }
    }
    
}



