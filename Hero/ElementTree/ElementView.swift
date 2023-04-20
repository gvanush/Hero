//
//  ElementView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI

let elementNavigationAnimation = Animation.easeOut(duration: 0.25)
let elementPropertyNavigationAnimation = Animation.easeOut(duration: 0.25)


extension Element {
    
    var body: some View {
        ZStack {
            faceView
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                propertyView
                elementGroupView(content, baseIndexPath: indexPath, offset: 0)
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
                withAnimation(elementNavigationAnimation) {
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
                    withAnimation(elementPropertyNavigationAnimation) {
                        activeProperty = prop
                    }
                }
        }
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    func elementGroupView(_ elements: (C1, C2, C3, C4, C5), baseIndexPath: IndexPath, offset: Int) -> some View {
        Group {
            elements.0
                .indexPath(baseIndexPath.appending(offset))
                .activeIndexPath(_activeIndexPath.projectedValue)
            
            elements.1
                .indexPath(baseIndexPath.appending(offset + elements.0.nodeCount))
                .activeIndexPath(_activeIndexPath.projectedValue)
            
            elements.2
                .indexPath(baseIndexPath.appending(offset + elements.0.nodeCount + elements.1.nodeCount))
                .activeIndexPath(_activeIndexPath.projectedValue)
            
            elements.3
                .indexPath(baseIndexPath.appending(offset + elements.0.nodeCount + elements.1.nodeCount + elements.2.nodeCount))
                .activeIndexPath(_activeIndexPath.projectedValue)
            
            elements.4
                .indexPath(baseIndexPath.appending(offset + elements.0.nodeCount + elements.1.nodeCount + elements.2.nodeCount + elements.3.nodeCount))
                .activeIndexPath(_activeIndexPath.projectedValue)
        }
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
