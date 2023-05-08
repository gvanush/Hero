//
//  ElementView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI

let elementNavigationAnimation = Animation.easeOut(duration: 0.25)
let elementPropertyNavigationAnimation = Animation.easeOut(duration: 0.25)
let elementActionViewHeigh = 75.0


extension Element {
    
    var body: some View {
        defaultBody
    }
    
    var defaultBody: some View {
        ZStack {
            
            faceView
                .visible(isChildOfActive)
                .onTapGesture {
                    withAnimation(elementNavigationAnimation) {
                        activeIndexPath = indexPath
                    }
                }
                .allowsHitTesting(isChildOfActive)
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                propertyView
                
                content
                    .indexPath(indexPath.appending(0))
                    .activeIndexPath(_activeIndexPath.projectedValue)
            }
            
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .overlay(alignment: .bottom) {
            Group {
                if isActive {
                    actionView
                        .frame(height: elementActionViewHeigh)
                        .offset(y: -elementSelectionViewHeight - 8.0)
                        .transition(.identity)
                }
            }
            .padding(-elementSelectionViewPadding)
        }
        .onChange(of: isDisclosed, perform: { newValue in
            if newValue {
                onDisclose()
            }
        })
        .onChange(of: isActive) { newValue in
            if newValue {
                onActive()
            } else {
                onInactive()
            }
        }
        .onChange(of: isDisclosed, perform: { newValue in
            if !newValue {
                onClose()
            }
        })
        .onChange(of: activeProperty) { _ in
            onActivePropertyChange()
        }
        .onAppear {
            
            onAwake()
            
            if isDisclosed {
                onDisclose()
            }
            
            if isActive {
                onActive()
            }
        }
        .onDisappear {
            if isActive {
                onInactive()
            }
            
            if isDisclosed {
                onClose()
            }
            
            onSleep()
        }
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
            .preference(key: DisclosedElementsPreferenceKey.self, value: isDisclosed ? [.init(id: id, title: title, subtitle: subtitle, indexPath: indexPath)] : [])
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
 
    private var textHorizontalScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
    private var distanceToActiveAncestor: Int? {
        guard indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return indexPath.count - activeIndexPath.count
    }
    
}


extension Element where ActionView == EmptyView {
    
    var actionView: ActionView {
        .init()
    }
    
}
